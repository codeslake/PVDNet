import torch
import torchvision.utils as vutils
import torch.nn.functional as F

import os
import sys
import datetime
import gc
from pathlib import Path

import numpy as np
import cv2
import math
from sklearn.metrics import mean_absolute_error
from skimage.metrics import structural_similarity
import collections

from utils import *
from data_loader.utils import refine_image, read_frame, load_file_list, norm
from ckpt_manager import CKPT_Manager

from models import create_model

def mae(img1, img2):
    mae_0=mean_absolute_error(img1[:,:,0], img2[:,:,0],
                              multioutput='uniform_average')
    mae_1=mean_absolute_error(img1[:,:,1], img2[:,:,1],
                              multioutput='uniform_average')
    mae_2=mean_absolute_error(img1[:,:,2], img2[:,:,2],
                              multioutput='uniform_average')
    return np.mean([mae_0,mae_1,mae_2])

def ssim(img1, img2, PIXEL_MAX = 1.0):
    return structural_similarity(img1, img2, data_range=PIXEL_MAX, multichannel=True)

def psnr(img1, img2, PIXEL_MAX = 1.0):
    mse_ = np.mean( (img1 - img2) ** 2 )
    return 10 * math.log10(PIXEL_MAX / mse_)

def init(config, mode = 'deblur'):
    date = datetime.datetime.now().strftime('%Y_%m_%d_%H%M')

    model = create_model(config)
    network = model.get_network().eval()

    ckpt_manager = CKPT_Manager(config.LOG_DIR.ckpt, config.mode, config.max_ckpt_num)
    load_state, ckpt_name = ckpt_manager.load_ckpt(network, by_score = config.EVAL.load_ckpt_by_score, name = config.EVAL.ckpt_name, abs_name = config.EVAL.ckpt_abs_name, epoch = config.EVAL.ckpt_epoch)
    print('\nLoading checkpoint \'{}\' on model \'{}\': {}'.format(ckpt_name, config.mode, load_state))

    save_path_root = config.EVAL.LOG_DIR.save

    save_path_root_deblur = os.path.join(save_path_root, mode, ckpt_name.split('.')[0])
    save_path_root_deblur_score = save_path_root_deblur
    Path(save_path_root_deblur).mkdir(parents=True, exist_ok=True)
    torch.save(network.state_dict(), os.path.join(save_path_root_deblur, ckpt_name))
    save_path_root_deblur = os.path.join(save_path_root_deblur, config.EVAL.data, date)

    blur_folder_path_list, blur_file_path_list, _ = load_file_list(config.EVAL.data_path, config.EVAL.input_path)
    gt_file_path_list = None
    if config.EVAL.gt_path is not None:
        _, gt_file_path_list, _ = load_file_list(config.EVAL.data_path, config.EVAL.gt_path)

    return network, save_path_root_deblur, save_path_root_deblur_score, ckpt_name, blur_folder_path_list, blur_file_path_list, gt_file_path_list

def eval_quan_qual(config):
    mode = 'quanti_quali'
    network, save_path_root_deblur, save_path_root_deblur_score, ckpt_name,\
    blur_folder_path_list, blur_file_path_list, gt_file_path_list = init(config, mode)

    ##
    total_norm = 0
    total_itr_time = 0
    PSNR_mean_total = 0.
    SSIM_mean_total = 0.
    for i in range(len(blur_file_path_list)):
        ## read frame
        frame_list = []
        video_name = blur_folder_path_list[i].split(os.sep)[-2]
        print('[Reading Frames: {}][{}/{}]'.format(video_name, i + 1, len(blur_file_path_list)))
        for frame_name in blur_file_path_list[i]:
            frame = refine_image(read_frame(frame_name), config.refine_val)
            frame = np.expand_dims(frame.transpose(0, 3, 1, 2), 0)
            frame_list.append(frame)

        if gt_file_path_list is not None:
            frame_list_gt = []
            for frame_name in gt_file_path_list[i]:
                frame = refine_image(read_frame(frame_name), config.refine_val)
                frame = np.expand_dims(frame.transpose(0, 3, 1, 2), 0)
                frame_list_gt.append(frame)

        ## evaluation start
        PSNR_mean = 0.
        SSIM_mean = 0.
        total_itr_time_video = 0
        for j in range(len(frame_list)):
            total_norm = total_norm + 1

            ## prepare input tensors

            index = np.array(list(range(j - 1, j + 2))).clip(min=0, max=len(frame_list)-1)
            Is = torch.cat([torch.FloatTensor(frame_list[k]).cuda() for k in index], dim = 1)
            I_center = torch.FloatTensor(frame_list[j][0]).cuda()

            #######################################################################
            ## run network
            with torch.no_grad():
                if j == 0:
                    I_prev_deblurred = Is[:, 0, :, :, :]

                I_prev = Is[:, 0, :, :, :]
                I_curr = Is[:, 1, :, :, :]
                I_next = Is[:, 2, :, :, :]

                torch.cuda.synchronize()
                init_time = time.time()
                out = network(I_prev, I_curr, I_next, I_prev_deblurred)
                I_prev_deblurred = out['result']

                torch.cuda.synchronize()
                itr_time = time.time() - init_time
                total_itr_time_video = total_itr_time_video + itr_time
                total_itr_time = total_itr_time + itr_time
            #######################################################################

            ## evaluation
            inp = norm(I_center)
            output = norm(out['result'])

            PSNR = 0 
            SSIM = 0 
            if gt_file_path_list is not None:
                gt = norm(torch.FloatTensor(frame_list_gt[j][0]).cuda())

                # quantitative
                output_cpu = output.cpu().numpy()[0].transpose(1, 2, 0)
                gt_cpu = gt.cpu().numpy()[0].transpose(1, 2, 0)

                PSNR = psnr(output_cpu, gt_cpu)
                SSIM = ssim(output_cpu, gt_cpu)

                PSNR_mean += PSNR
                SSIM_mean += SSIM

            frame_name = os.path.basename(blur_file_path_list[i][j])
            print('[EVAL {}|{}|{}][{}/{}][{}/{}] {} PSNR: {:.5f}, SSIM: {:.5f} ({:.5f}sec)'.format(config.mode, config.EVAL.data, video_name, i + 1, len(blur_file_path_list), j + 1, len(frame_list), frame_name, PSNR, SSIM, itr_time))
            with open(os.path.join(save_path_root_deblur_score, 'score_{}.txt'.format(config.EVAL.data)), 'w' if (i == 0 and j == 0) else 'a') as file:
                file.write('[EVAL {}|{}|{}][{}/{}][{}/{}] {} PSNR: {:.5f}, SSIM: {:.5f} ({:.5f}sec)\n'.format(config.mode, config.EVAL.data, video_name, i + 1, len(blur_file_path_list), j + 1, len(frame_list), frame_name, PSNR, SSIM, itr_time))
                file.close()

            # qualitative
            for iformat in ['png', 'jpg']:
                frame_name_no_ext = frame_name.split('.')[0]
                save_path_deblur = os.path.join(save_path_root_deblur, iformat)
                Path(save_path_deblur).mkdir(parents=True, exist_ok=True)

                Path(os.path.join(save_path_deblur, 'input', video_name)).mkdir(parents=True, exist_ok=True)
                save_file_path_deblur_input = os.path.join(save_path_deblur, 'input', video_name, '{}.{}'.format(frame_name_no_ext, iformat))
                vutils.save_image(inp, '{}'.format(save_file_path_deblur_input), nrow=1, padding = 0, normalize = False)

                Path(os.path.join(save_path_deblur, 'output', video_name)).mkdir(parents=True, exist_ok=True)
                save_file_path_deblur_output = os.path.join(save_path_deblur, 'output', video_name, '{}.{}'.format(frame_name_no_ext, iformat))
                vutils.save_image(output, '{}'.format(save_file_path_deblur_output), nrow=1, padding = 0, normalize = False)

                if gt_file_path_list is not None:
                    Path(os.path.join(save_path_deblur, 'gt', video_name)).mkdir(parents=True, exist_ok=True)
                    save_file_path_deblur_gt = os.path.join(save_path_deblur, 'gt', video_name, '{}.{}'.format(frame_name_no_ext, iformat))
                    vutils.save_image(gt, '{}'.format(save_file_path_deblur_gt), nrow=1, padding = 0, normalize = False)


        # video average
        PSNR_mean_total += PSNR_mean
        PSNR_mean = PSNR_mean / len(frame_list)

        SSIM_mean_total += SSIM_mean
        SSIM_mean = SSIM_mean / len(frame_list)

        print('[MEAN EVAL {}|{}|{}][{}/{}] {} PSNR: {:.5f}, SSIM: {:.5f} ({:.5f}sec)\n\n'.format(config.mode, config.EVAL.data, video_name, i + 1, len(blur_file_path_list), frame_name, PSNR_mean, SSIM_mean, total_itr_time_video / len(frame_list)))
        with open(os.path.join(save_path_root_deblur_score, 'score_{}.txt'.format(config.EVAL.data)), 'a') as file:
            file.write('[MEAN EVAL {}|{}|{}][{}/{}] {} PSNR: {:.5f}, SSIM: {:.5f} ({:.5f}sec)\n\n'.format(config.mode, config.EVAL.data, video_name, i + 1, len(blur_file_path_list), frame_name, PSNR_mean, SSIM_mean, total_itr_time_video / len(frame_list)))
            file.close()

        gc.collect()

    # total average
    total_itr_time = total_itr_time / total_norm
    PSNR_mean_total = PSNR_mean_total / total_norm
    SSIM_mean_total = SSIM_mean_total / total_norm

    sys.stdout.write('\n[TOTAL {}|{}] PSNR: {:.5f} SSIM: {:.5f} ({:.5f}sec)'.format(ckpt_name, config.EVAL.data, PSNR_mean_total, SSIM_mean_total, total_itr_time))
    with open(os.path.join(save_path_root_deblur_score, 'score_{}.txt'.format(config.EVAL.data)), 'a') as file:
        file.write('\n[TOTAL {}|{}] PSNR: {:.5f} SSIM: {:.5f} ({:.5f}sec)\n'.format(ckpt_name, config.EVAL.data, PSNR_mean_total, SSIM_mean_total, total_itr_time))
        file.close()

def eval(config):
    # if config.EVAL.eval_mode == 'quan':
    #     eval_quan(config)
    eval_quan_qual(config)

