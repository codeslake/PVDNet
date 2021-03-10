from easydict import EasyDict as edict
import json
import os
import collections
import numpy as np

def get_config(project = '', mode = '', config_ = '', batch_size = 8):
    ## GLOBAL
    config = edict()
    config.project = project
    config.mode = mode
    config.config = config_
    config.is_train = False
    config.thread_num = 1
    config.dist = False
    config.resume = None # 'resume epoch'
    config.manual_seed = 0
    config.is_verbose = False
    config.save_sample = False

    ##################################### TRAIN #####################################
    config.trainer = ''
    config.network = ''

    config.in_bit = 8
    config.norm_val = (2**config.in_bit - 1)

    config.batch_size = batch_size
    config.batch_size_test = 1
    config.height = 256
    config.width = 256

    # learning rate
    config.lr_init = 1e-4
    config.gc = 1.0

    ## Naive Decay
    config.LRS = 'LD' # LD
    config.total_itr = 600000
    config.decay_period = [500000, 550000]
    config.decay_rate = 0.5
    config.warmup_itr = -1

    # adam
    config.beta1 = 0.9

    # data dir
    config.data = 'DVD'
    config.data_offset = '/data1/junyonglee/video_deblur'
    config.data_path = None
    config.input_path = None
    config.gt_path = None

    # logs
    config.max_ckpt_num = 100
    config.write_ckpt_every_epoch = 4
    config.refresh_image_log_every_epoch = {'train':200, 'valid':200}
    config.write_log_every_itr = {'train':40, 'valid': 20}

    # log dirs
    config.LOG_DIR = edict()
    offset = '/Jarvis/logs/junyonglee'
    offset = os.path.join(offset, config.project)
    offset = os.path.join(offset, '{}'.format(mode))
    config.LOG_DIR.offset = offset
    config.LOG_DIR.ckpt = os.path.join(config.LOG_DIR.offset, 'checkpoint', 'train', 'epoch')
    config.LOG_DIR.ckpt_ckpt = os.path.join(config.LOG_DIR.offset, 'checkpoint', 'train', 'epoch', 'ckpt')
    config.LOG_DIR.ckpt_state = os.path.join(config.LOG_DIR.offset, 'checkpoint', 'train', 'epoch', 'state')
    config.LOG_DIR.log_scalar = os.path.join(config.LOG_DIR.offset, 'log', 'train', 'scalar')
    config.LOG_DIR.log_image = os.path.join(config.LOG_DIR.offset, 'log', 'train', 'image', 'train')
    config.LOG_DIR.sample = os.path.join(config.LOG_DIR.offset, 'sample', 'train')
    config.LOG_DIR.sample_val = os.path.join(config.LOG_DIR.offset, 'sample', 'valid')
    config.LOG_DIR.config = os.path.join(config.LOG_DIR.offset, 'config')

    ################################## VALIDATION ###################################
    # data path
    config.VAL = edict()
    config.VAL.data_path = None
    config.VAL.input_path = None
    config.VAL.gt_path = None

    ##################################### EVAL ######################################
    config.EVAL = edict()
    config.EVAL.eval_mode = 'quan'
    config.EVAL.data = 'DVD' 

    config.EVAL.load_ckpt_by_score = True
    config.EVAL.ckpt_name = None
    config.EVAL.ckpt_epoch = None
    config.EVAL.ckpt_abs_name = None
    config.EVAL.low_res = False
    config.EVAL.ckpt_load_path = None

    # data dir
    config.EVAL.data_path = None
    config.EVAL.input_path = None
    config.EVAL.gt_path = None

    # log dir
    config.EVAL.LOG_DIR = edict()
    config.EVAL.LOG_DIR.save = os.path.join(config.LOG_DIR.offset, 'result')

    return config

def set_train_path(config, data):
    if data == 'DVD':
        config.data_path = os.path.join(config.data_offset, 'train_DVD')
        config.input_path = 'input' 
        config.gt_path = 'GT'

        config.VAL.data_path = os.path.join(config.data_offset, 'test_DVD')
        config.VAL.input_path = 'input' 
        config.VAL.gt_path = 'GT'

    elif data == 'nah':
        config.data_path = os.path.join(config.data_offset, 'train_nah')
        config.input_path = 'blur_gamma'
        config.gt_path = 'sharp'

        config.VAL.data_path = os.path.join(config.data_offset, 'test_nah')
        config.VAL.input_path = 'blur_gamma'
        config.VAL.gt_path = 'sharp'

    return config

def set_eval_path(config, data):
    if data == 'DVD':
        config.EVAL.data_path = os.path.join(config.data_offset, 'test_DVD')
        config.EVAL.input_path = 'input' 
        config.EVAL.gt_path = 'GT'

    elif data == 'nah':
        config.EVAL.data_path = os.path.join(config.data_offset, 'test_nah')
        config.EVAL.input_path = 'blur_gamma' # os.path.join(config.VAL.data_path, 'input')
        config.EVAL.gt_path = 'sharp' # os.path.join(config.VAL.data_path, 'gt')
    elif data == 'any':
        config.EVAL.data_path = 'datasets/any'
        config.EVAL.input_path = 'source' # os.path.join(config.VAL.data_path, 'input')

    return config

def log_config(path, cfg):
    with open(path + '/config.txt', 'w') as f:
        f.write(json.dumps(cfg, indent=4))
        f.close()

def print_config(cfg):
    print(json.dumps(cfg, indent=4))

