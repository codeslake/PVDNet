import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.nn.parallel import DataParallel as DP
from torch.nn.parallel import DistributedDataParallel as DDP
import numpy as np
import collections
import torch_optimizer as optim
import torch.nn.utils as torch_utils

from utils import *
from data_loader.utils import *
from models.utils import *
from models.baseModel import baseModel
from models.pixel_volume import get_pixel_volume

from data_loader.datasets import datasets
import models.trainers.lr_scheduler as lr_scheduler

from data_loader.data_sampler import DistIterSampler

from ptflops import get_model_complexity_info
import importlib
from shutil import copy2
import os

class Model(baseModel):
    def __init__(self, config):
        super(Model, self).__init__(config)
        self.rank = torch.distributed.get_rank() if config.dist else -1
        self.ws = torch.distributed.get_world_size() if config.dist else 1

        ### NETWORKS ###
        if self.rank <= 0 : print(toGreen('Loading Model...'))
        self.network = DeblurNet(config).to(torch.device('cuda'))

        if self.is_train and self.config.resume is None or self.is_train and os.path.exists('./models/archs/{}.py'.format(config.network)):
            copy2('./models/archs/{}.py'.format(config.network), self.config.LOG_DIR.offset)
            copy2('./models/archs/{}.py'.format(config.network_BIMNet), self.config.LOG_DIR.offset)

        ### PROFILE ###
        if self.rank <= 0:
            with torch.no_grad():
                Macs,params = get_model_complexity_info(self.network, (1, 3, 720, 1280), input_constructor = self.network.input_constructor, as_strings=False,print_per_layer_stat=config.is_verbose)

        ### INIT for training ###
        if self.is_train:
            self.itr_global = {'train': 0, 'valid': 0}
            self.itr_inc = {'train': self.config.frame_itr_num, 'valid': 1}
            self.network.init()
            self._set_optim()
            self._set_lr_scheduler()
            self._set_dataloader()

            if config.is_verbose:
                for name, param in self.network.named_parameters():
                    if self.rank <= 0: print(name, ', ', param.requires_grad)

        ### DDP ###
        if config.dist:
            if self.rank <= 0: print(toGreen('Building Dist Parallel Model...'))
            self.network = DDP(self.network, device_ids=[torch.cuda.current_device()], output_device=torch.cuda.current_device(), broadcast_buffers=True, find_unused_parameters=False)
        else:
            self.network = DP(self.network).to(torch.device('cuda'))

        if self.rank <= 0:
            print(toGreen('Computing model complexity...'))
            print('{:<30}  {:<8} B'.format('Computational complexity (Macs): ', Macs / 1000 ** 3 ))
            print('{:<30}  {:<8} M'.format('Number of parameters: ',params / 1000 ** 2))
            if self.is_train:
                with open(config.LOG_DIR.offset + '/cost.txt', 'w') as f:
                    f.write('{:<30}  {:<8} B\n'.format('Computational complexity (Macs): ', Macs / 1000 ** 3 ))
                    f.write('{:<30}  {:<8} M'.format('Number of parameters: ',params / 1000 ** 2))
                    f.close()

    def get_itr_per_epoch(self, state):
        if state == 'train':
            return len(self.data_loader_train) * self.itr_inc[state]
        else:
            return len(self.data_loader_eval) * self.itr_inc[state]

    def _set_loss(self, lr = None):
        if self.rank <= 0: print(toGreen('Building Loss...'))
        self.MSE = torch.nn.MSELoss().to(torch.device('cuda'))
        self.MAE = torch.nn.L1Loss().to(torch.device('cuda'))
        self.CSE = torch.nn.CrossEntropyLoss(reduction='none').to(torch.device('cuda'))
        self.MSE_sum = torch.nn.MSELoss(reduction = 'sum').to(torch.device('cuda'))

    def _set_optim(self, lr = None):
        if self.rank <= 0: print(toGreen('Building Optim...'))
        self._set_loss()
        lr = self.config.lr_init if lr is None else lr

        self.optimizer = optim.RAdam([
            {'params': self.network.parameters(), 'lr': self.config.lr_init, 'lr_init': self.config.lr_init}
            ], eps= 1e-8, weight_decay=0.01, lr=lr, betas=(self.config.beta1, 0.999))

        self.optimizers.append(self.optimizer)

    def _set_lr_scheduler(self):
        if self.rank <= 0: print(toGreen('Loading Learning Rate Scheduler...'))
        if self.config.LRS == 'CA':
            if self.rank <= 0: print(toRed('\tCosine annealing scheduler...'))
            for optimizer in self.optimizers:
                self.schedulers.append(
                    lr_scheduler.CosineAnnealingLR_Restart(
                        optimizer, self.config.T_period, eta_min= self.config.eta_min,
                        restarts= self.config.restarts, weights= self.config.restart_weights))
        elif self.config.LRS == 'LD':
            if self.rank <= 0: print(toRed('\tLR dacay scheduler...'))
            for optimizer in self.optimizers:
                self.schedulers.append(
                    lr_scheduler.LR_decay(
                        optimizer, decay_period = self.config.decay_period,
                        decay_rate = self.config.decay_rate))

    def _set_dataloader(self):
        if self.rank <= 0: print(toGreen('Loading Data Loader...'))

        self.sampler_train = None
        self.sampler_eval = None

        self.dataset_train = datasets(self.config, is_train = True)
        self.dataset_eval = datasets(self.config, is_train = False)

        if self.config.dist == True:
            self.sampler_train = DistIterSampler(self.dataset_train, self.ws, self.rank)
            self.sampler_eval = DistIterSampler(self.dataset_eval, self.ws, self.rank, is_train=False)
        else:
            self.sampler_train = None
            self.sampler_eval = None

        if self.is_train:
            self.data_loader_train = self._create_dataloader(self.dataset_train, sampler = self.sampler_train, is_train = True)
            self.data_loader_eval = self._create_dataloader(self.dataset_eval, sampler = self.sampler_eval, is_train = False)

    def _update(self, errs, warmup_itr = -1):
        lr = None
        self.optimizer.zero_grad()
        errs['total'].backward()

        torch_utils.clip_grad_norm_(self.network.parameters(), self.config.gc)
        self.optimizer.step()
        lr = self._update_learning_rate(self.itr_global['train'], warmup_itr)

        return lr

    ######################################################################################################
    ########################### Edit from here for training/testing scheme ###############################
    ######################################################################################################

    def _set_results(self, inputs, outs, errs, norm_, lr, is_train):
        ## save visuals (inputs)
        if self.rank <=0 and self.config.save_sample:
            self.results['inputs'] = collections.OrderedDict()
            self.results['inputs']['input'] = norm(inputs['input'][0:1, -1, :, :, :])
            self.results['inputs']['gt'] = norm(inputs['gt'][0:1, -1, :, :, :])

            ## save visuals (outputs)
            self.results['outs'] = {}
            self.results['outs']['result'] = norm(outs['result'][0:1])
            self.results['outs']['warped_bb'] = outs['warped_bb'][0:1]
            if self.config.fix_BIMNet is False:
                self.results['outs']['warped_bs'] = outs['warped_bb'][0:1]
                self.results['outs']['warped_sb'] = outs['warped_bb'][0:1]
                self.results['outs']['warped_ss'] = outs['warped_bb'][0:1]

        ## essential ##
        # save scalars
        self.results['errs'] = errs
        self.results['norm'] = norm_
        # learning rate
        self.results['lr'] = lr

    def _get_results(self, I_prev, I_curr, I_next, I_prev_deblurred, gt_prev, gt_curr, is_train):

        outs = self.network(I_prev, I_curr, I_next, I_prev_deblurred, gt_prev, gt_curr, is_train)

        ## loss
        if self.config.is_train:
            errs = collections.OrderedDict()
            if 'result' in outs.keys():
                errs['total'] = 0.
                # deblur loss
                errs['image'] = self.MSE(outs['result'], gt_curr)
                errs['total'] = errs['total'] + errs['image']

            if is_train:
                if self.config.fix_BIMNet is False:
                    # flow loss
                    err_bb = self.MSE_sum(outs['warped_bb'], norm(gt_curr) * outs['warped_bb_mask']) / outs['warped_bb_mask'].sum()
                    err_bs = self.MSE_sum(outs['warped_bs'], norm(gt_curr) * outs['warped_bs_mask']) / outs['warped_bs_mask'].sum()
                    err_sb = self.MSE_sum(outs['warped_sb'], norm(gt_curr) * outs['warped_sb_mask']) / outs['warped_sb_mask'].sum()
                    err_ss = self.MSE_sum(outs['warped_ss'], norm(gt_curr) * outs['warped_ss_mask']) / outs['warped_ss_mask'].sum()
                    errs['flow'] = (err_bb + err_bs + err_sb + err_ss) / 4.
                    errs['total'] = errs['total'] + errs['flow']
            else:
                errs['psnr'] = get_psnr2(norm(outs['result']), norm(gt_curr))

            return errs, outs
        else:
            return outs

    def iteration(self, inputs, epoch, max_epoch, is_log, is_train):
        # init for logging
        state = 'train' if is_train else 'valid'
        self.itr_global[state] += self.itr_inc[state]

        # prepare data
        Is = refine_image_pt(inputs['input'].to(torch.device('cuda')), self.config.refine_val)
        GTs = refine_image_pt(inputs['gt'].to(torch.device('cuda')), self.config.refine_val)

        errs_total = {}
        if is_train or is_train is False and inputs['is_first']:
            self.I_prev_deblurred = Is[:, 0, :, :, :]

        norm_ = 0
        for i in range(Is.size()[1]-2):
            # run network & get errs and outputs
            I_prev = Is[:, i, :, :, :]
            I_curr = Is[:, i+1, :, :, :]
            I_next = Is[:, i+2, :, :, :]

            gt_prev = GTs[:, i, :, :, :]
            gt_curr = GTs[:, i+1, :, :, :]

            errs, outs = self._get_results(I_prev, I_curr, I_next, self.I_prev_deblurred, gt_prev, gt_curr, is_train)
            self.I_prev_deblurred = outs['result'].detach()

            # update network & get learning rate
            lr = self._update(errs, self.config.warmup_itr) if is_train else None

            norm_ += outs['result'].size()[0]
            for k, v in errs.items():
                v_t = 0 if i == 0 else errs_total[k]
                errs_total[k] = v_t + v * outs['result'].size()[0]

        assert norm_ != 0

        # set results for the log
        self._set_results(inputs, outs, errs_total, norm_, lr, is_train)

class DeblurNet(nn.Module):
    def __init__(self, config):
        super(DeblurNet, self).__init__()
        self.rank = torch.distributed.get_rank() if config.dist else -1
        self.config = config

        if self.rank <= 0: print(toRed('\tinitializing deblurring network'))

        # BIMNet
        lib = importlib.import_module('models.archs.{}'.format(config.network_BIMNet))
        self.BIMNet = lib.Network()

        # PVDNet
        lib = importlib.import_module('models.archs.{}'.format(config.network))
        self.PVDNet = lib.Network(config.PV_ksize ** 2)

    def weights_init(self, m):
        if isinstance(m, torch.nn.Conv2d) or isinstance(m, torch.nn.ConvTranspose2d):
            torch.nn.init.xavier_uniform_(m.weight, gain = self.config.wi)
            if m.bias is not None:
                torch.nn.init.constant_(m.bias, 0)
            elif type(m) == torch.nn.BatchNorm2d or type(m) == torch.nn.InstanceNorm2d:
                if m.weight is not None:
                    torch.nn.init.constant_(m.weight, 1)
                    torch.nn.init.constant_(m.bias, 0)
            elif type(m) == torch.nn.Linear:
                torch.nn.init.normal_(m.weight, 0, 0.01)
                torch.nn.init.constant_(m.bias, 0)

    def init(self):
        if self.config.fix_BIMNet:
            print('\t\tBIMNet loaded: ', self.BIMNet.load_state_dict(torch.load('./ckpt/BIMNet.pytorch')))
            if self.rank <= 0: print(toRed('\t\tBIMNet fixed'))
            for param in self.BIMNet.parameters():
                param.requires_grad_(False)
        else:
            self.BIMNet.apply(self.weights_init)

        self.PVDNet.apply(self.weights_init)

    def input_constructor(self, res):
        b, c, h, w = res[:]

        img = torch.FloatTensor(np.random.randn(b, c, h, w)).cuda()

        return {'I_prev': img, 'I_curr': img, 'I_next': img, 'I_prev_deblurred': img}

    #####################################################
    def forward(self, I_prev, I_curr, I_next, I_prev_deblurred, gt_prev=None, gt_curr=None, is_train=False):
        _, _, h, w = I_curr.size()

        refine_h = h - h % 32 # 32:mod crop for liteflownet
        refine_w = w - w % 32
        I_curr_refined = I_curr[:, :, 0 : refine_h, 0 : refine_w]
        I_prev_refined = I_prev[:, :, 0 : refine_h, 0 : refine_w]

        outs = collections.OrderedDict()
        ## BIMNet
        w_bb = upsample(self.BIMNet(norm(I_curr_refined ), norm(I_prev_refined )), refine_h, refine_w)
        if refine_h != h or refine_w != w:
            w_bb = F.pad(w_bb,(0, w - refine_w, 0, h - refine_h, 0, 0, 0, 0))

        ## PVDNet
        outs['PV'] = get_pixel_volume(I_prev_deblurred, w_bb, I_curr, h, w) # C: 5 X 5 (gray) X 3 (color)
        outs['result'] = self.PVDNet(outs['PV'], I_prev, I_curr, I_next)

        if is_train and self.config.fix_BIMNet is False:
            gt_curr_refined = gt_curr[:, :, 0 : refine_h, 0 : refine_w]
            gt_prev_refined = gt_prev[:, :, 0 : refine_h, 0 : refine_w]

            w_bs = upsample(self.BIMNet(norm(gt_curr_refined), norm(I_prev_refined )), refine_h, refine_w)
            w_sb = upsample(self.BIMNet(norm(I_curr_refined ), norm(gt_prev_refined)), refine_h, refine_w)
            w_ss = upsample(self.BIMNet(norm(gt_curr_refined), norm(gt_prev_refined)), refine_h, refine_w)

            if refine_h != h or refine_w != w:
                w_bs = F.pad(w_bs,(0, w - refine_w, 0, h - refine_h, 0, 0, 0, 0))
                w_sb = F.pad(w_sb,(0, w - refine_w, 0, h - refine_h, 0, 0, 0, 0))
                w_ss = F.pad(w_ss,(0, w - refine_w, 0, h - refine_h, 0, 0, 0, 0))

            outs['warped_bb'] = warp(norm(gt_prev), w_bb)
            outs['warped_bs'] = warp(norm(gt_prev), w_bs)
            outs['warped_sb'] = warp(norm(gt_prev), w_sb)
            outs['warped_ss'] = warp(norm(gt_prev), w_ss)

            with torch.no_grad():
                outs['warped_bb_mask'] = warp(torch.ones_like(gt_prev), w_bb)
                outs['warped_bs_mask'] = warp(torch.ones_like(gt_prev), w_bs)
                outs['warped_sb_mask'] = warp(torch.ones_like(gt_prev), w_sb)
                outs['warped_ss_mask'] = warp(torch.ones_like(gt_prev), w_ss)
        elif self.config.save_sample and gt_prev is not None:
            outs['warped_bb'] = warp(norm(gt_prev), w_bb)


        return outs

