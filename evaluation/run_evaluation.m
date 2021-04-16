%% init
clear all; close all;

addpath('evaluation_code');
addpath('evaluation_code\image_quality_algorithms');
addpath('evaluation_code\image_quality_algorithms\metrix_mux');
addpath('evaluation_code\image_quality_algorithms\metrix_mux\metrix');
addpath('evaluation_code\image_quality_algorithms\metrix_mux\metrix\ssim');

delete(gcp('nocreate'));
parpool(4);

%% gt path
% test_offet = './datasets';
test_offset = '\\mango.postech.ac.kr\Users\junyonglee\hub\datasets\video_deblur';

%% result path
% result_root = './logs/PVDNet_TOG2021';
result_root = '\\jarvis.postech.ac.kr\logs\junyonglee\PVDNet_TOG2021';

% PVDNet_DVD
test_model = 'PVDNet_DVD';
folder_result = fullfile(result_root, 'PVDNet_DVD\result\quanti_quali\PVDNet_DVD\DVD\2021_04_15_0131\png\output');
psnr_mean, ssim_mean = evaluation(test_model, folder_result, 'DVD', test_offset);
fprintf('PSNR (Koehler): %f, SSIM (Koehler): %f', psnr_mean, ssim_mean);

% % PVDNet_nah
% test_model = 'PVDNet_nah';
% folder_result = fullfile(result_root, 'PVDNet_nah\result\quanti_quali\PVDNet_nah\nah\2021_04_15_0131\png\output');
% psnr_mean, ssim_mean = evaluation(test_model, folder_result, 'nah', test_offset);
% fprintf('PSNR (Koehler): %f, SSIM (Koehler): %f', psnr_mean, ssim_mean);

% % PVDNet_large_nah
% test_model = 'PVDNet_large_nah';
% folder_result = fullfile(result_root, 'PVDNet_large_nah\result\quanti_quali\PVDNet_large_nah\nah\2021_04_15_0132\png\output');
% psnr_mean, ssim_mean = evaluation(test_model, folder_result, 'nah', test_offset);
% fprintf('PSNR (Koehler): %f, SSIM (Koehler): %f', psnr_mean, ssim_mean);

