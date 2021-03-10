'''
REDS dataset
support reading images from lmdb, image folder and memcached
'''
import os
import random
import numpy as np
import cv2
import torch
import torch.utils.data as data

from data_loader.utils import *

class datasets(data.Dataset):
    def __init__(self, config, is_train):
        super(datasets, self).__init__()
        self.config = config
        self.is_train = is_train
        self.h = config.height
        self.w = config.width
        self.frame_num = config.frame_num
        self.frame_half = int(self.frame_num / 2)
        self.rank = torch.distributed.get_rank()

        if self.is_train:
            self.input_folder_path_list, self.input_file_path_list, _ = load_file_list(config.data_path, config.input_path)
            self.gt_folder_path_list, self.gt_file_path_list, _ = load_file_list(config.data_path, config.gt_path)
            self.frame_itr_num = config.frame_itr_num
        else:
            self.input_folder_path_list, self.input_file_path_list, _ = load_file_list(config.VAL.data_path, config.VAL.input_path)
            self.gt_folder_path_list, self.gt_file_path_list, _ = load_file_list(config.VAL.data_path, config.VAL.gt_path)
            self.frame_itr_num = 1

        self._init_idx()
        if self.is_train is False:
            idx_frame_acc = self.idx_frame.copy()
            length = 0
            for i in range(1, len(idx_frame_acc)):
                length = length + len(idx_frame_acc[i-1])
                temp = (np.array(idx_frame_acc[i]) + length).tolist()
                idx_frame_acc[i] = temp
            self.idx_frame_acc = idx_frame_acc

        self.len = int(np.ceil(len(self.idx_frame_flat)))

    def _init_idx(self):
        self.idx_video = []
        self.idx_frame_flat = []
        self.idx_frame = []
        for i in range(len(self.input_file_path_list)):
            total_frames = len(self.input_file_path_list[i])

            if self.is_train:
                idx_frame_temp = list(range(0, total_frames - self.frame_itr_num + 1, self.frame_itr_num))
            else:
                idx_frame_temp = list(range(0, total_frames - self.frame_itr_num + 1))

            self.idx_frame_flat.append(idx_frame_temp)
            self.idx_frame.append(idx_frame_temp)

            for j in range(len(idx_frame_temp)):
                self.idx_video.append(i)

        self.idx_frame_flat = sum(self.idx_frame_flat, [])

    def __len__(self):
        return self.len

    def __getitem__(self, index):
        video_idx = self.idx_video[index]
        frame_offset = self.idx_frame_flat[index] - self.frame_half
        input_file_path = self.input_file_path_list[video_idx]
        gt_file_path = self.gt_file_path_list[video_idx]

        sampled_frame_idx = np.arange(frame_offset, frame_offset + self.frame_num + self.frame_itr_num - 1)
        sampled_frame_idx = sampled_frame_idx.clip(min = 0, max = len(input_file_path) - 1)

        input_patches_temp = [None] * len(sampled_frame_idx)
        gt_patches_temp = [None] * len(sampled_frame_idx)
        for frame_idx in range(len(sampled_frame_idx)):
            sampled_idx = sampled_frame_idx[frame_idx]

            assert(get_folder_name(str(Path(input_file_path[sampled_idx]).parent)) == get_folder_name(str(Path(gt_file_path[sampled_idx]).parent)))
            assert(get_base_name(input_file_path[sampled_idx]) == get_base_name(gt_file_path[sampled_idx]))

            input_img = read_frame(input_file_path[sampled_idx])
            gt_img = read_frame(gt_file_path[sampled_idx])
            if self.is_train:
                if random.uniform(0, 1) <= 0.5:
                # if random.uniform(0, 1) >= 0.0:
                    row,col,ch = input_img[0].shape
                    mean = 0
                    gauss = np.random.normal(mean,1e-4,(row,col,ch))
                    gauss = gauss.reshape(row,col,ch)

                    input_img = np.expand_dims(np.clip(input_img[0] + gauss, 0.0, 1.0), axis = 0)

            input_patches_temp[frame_idx] = input_img
            gt_patches_temp[frame_idx] = gt_img

        input_patches_temp = np.concatenate(input_patches_temp[:len(sampled_frame_idx)], axis = 3)
        gt_patches_temp = np.concatenate(gt_patches_temp[:len(sampled_frame_idx)], axis = 3)

        cropped_frames = np.concatenate([input_patches_temp, gt_patches_temp], axis = 3)

        if self.is_train:
            cropped_frames = crop_multi(cropped_frames, self.h, self.w, is_random = True)
        # else:
        #     cropped_frames = crop_multi(cropped_frames, self.h, self.w, is_random = False)

        input_patches = cropped_frames[:, :, :, 0:len(sampled_frame_idx) * 3]
        shape = input_patches.shape
        h = shape[1]
        w = shape[2]
        input_patches = input_patches.reshape((h, w, -1, 3))
        input_patches = torch.FloatTensor(np.transpose(input_patches, (2, 3, 0, 1)))

        gt_patches = cropped_frames[:, :, :, len(sampled_frame_idx) * 3:]
        gt_patches = gt_patches.reshape((h, w, -1, 3))
        gt_patches = torch.FloatTensor(np.transpose(gt_patches, (2, 3, 0, 1)))
        gt_patches = gt_patches[:, :, :, :]

        is_first = True
        if self.idx_video[index] == self.idx_video[index - 1]:
            is_first = False

        return {'input': input_patches, 'gt': gt_patches, 'is_first': is_first}


