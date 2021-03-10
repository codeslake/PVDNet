from configs.config import get_config as main_config
from configs.config import log_config, print_config
import math
import torch
import numpy as np

def get_config(project = '', mode = '', config = '', batch_size = 8):

    ## GLOBAL
    config = main_config(project, mode, config, batch_size)

    ## LOCAL
    actual_batch_size = config.batch_size * torch.cuda.device_count()
    # config.lr_init = config.lr_init * math.sqrt(64./8.)

    config.lr_init = 1e-4
    config.trainer = 'trainer'
    config.network_BIMNet = 'liteFlowNet'
    config.network = 'PVDNet'
    config.PV_ksize = 5
    config.fix_BIMNet = True

    ## data
    config.frame_itr_num = 13
    config.frame_num = 3

    config.refine_val = 32
    config.wi = 1.0 # weight init

    ## training schedule
    if config.data == 'nah':
        total_frame_num = int(6309/3)
        video_num = 22 # video num
    elif config.data == 'DVD':
        total_frame_num = int(11416/2)
        video_num = 61 # video num

    config.total_itr = 600000
    IpE = math.ceil((len(list(range(0, total_frame_num - (config.frame_itr_num-1), config.frame_itr_num)))) / actual_batch_size) * config.frame_itr_num

    our_epoch = math.ceil(config.total_itr / IpE)

    config.decay_period = [400000]
    config.decay_rate = 0.25

    return config
