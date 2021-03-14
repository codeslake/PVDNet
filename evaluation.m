
clear all; close all;
addpath('evaluation_code');
addpath('evaluation_code\image_quality_algorithms');
addpath('evaluation_code\image_quality_algorithms\metrix_mux');
addpath('evaluation_code\image_quality_algorithms\metrix_mux\metrix');
addpath('evaluation_code\image_quality_algorithms\metrix_mux\metrix\ssim');

%%
test_offet = './datasets';

test_set = 'nah' % DVD,
if strcmp(test_set, 'DVD')
    folder = [test_offset, '/test_DVD'];
elseif strcmp(test_set, 'nah')
    folder = [test_offset, '/test_nah'];
end
result_root = './logs/PVDNet_TOG2021';

test_model = 'PVDNet_DVD';
folder_input = [result_root, '/PVDNet_DVD/result/..'];

% test_model = 'PVDNet_nah';
% folder_input = [result_root, '/PVDNet_nah/result/..'];

% test_model = 'PVDNet_large_nah';
% folder_input = [result_root, '/PVDNet_large_nah/result/..'];

%%
folderpaths = dir(fullfile(folder));
folderpaths = folderpaths(3:end);

psnr_list_total_frame = [];
psnr_list_total = [];
psnr_list = [];

ssim_list_total_frame = [];
ssim_list_total = [];
ssim_list = [];

psnr_shift_list_total_frame = [];
psnr_shift_list_total = [];
psnr_shift_list = [];

ssim_shift_list_total_frame = [];
ssim_shift_list_total = [];
ssim_shift_list = [];

cropsize = 16;
delete(gcp('nocreate'));

%%
parpool(4)
for i = 1:length(folderpaths)

    if strcmp(test_set, 'DVD')
        filepaths_GT = dir(fullfile(folder, folderpaths(i).name,'GT','*.jpg'));
    elseif strcmp(test_set, 'nah')
        filepaths_GT = dir(fullfile(folder, folderpaths(i).name,'sharp','*.png'));
    end
    
    filepaths_input = dir(fullfile(folder_input, folderpaths(i).name,'*.png'));
    
    num = length(filepaths_input);
    start_idx = 2;
    parfor j = start_idx:num
    %for j = 2:num
        disp([num2str(i), '/', num2str(length(folderpaths)), ' ', num2str(j), '/', num2str(num)]);

        if strcmp(test_model, 'OVD')
            GT_idx = j + 1;
        else
            GT_idx = j;
        end
        
        if strcmp(test_set, 'DVD')
            GT = imread(fullfile(folder,folderpaths(i).name,'GT', filepaths_GT(GT_idx).name));
        elseif strcmp(test_set, 'nah')
            GT = imread(fullfile(folder,folderpaths(i).name,'sharp', filepaths_GT(GT_idx).name));  
        end
        
        if size(GT,2) ~= 1280
            GT = permute(GT,[2,1,3]);
        end
        
        input = imread(fullfile(folder_input,folderpaths(i).name,filepaths_input(j).name));
        if size(input,2) ~= 1280
            input = permute(input,[2,1,3]);
        end        
                
        GT = GT(1+cropsize:end-cropsize,1+cropsize:end-cropsize,:);
        input = input(1+cropsize:end-cropsize,1+cropsize:end-cropsize,:);    
        
        psnr_list = [psnr_list, psnr(im2double(GT),im2double(input))];
        psnr_list_total_frame = [psnr_list_total_frame, psnr(im2double(GT),im2double(input))];

        ssim_list = [ssim_list, ssim(im2double(GT),im2double(input))];
        ssim_list_total_frame = [ssim_list_total_frame, ssim(im2double(GT),im2double(input))];

        z = double(input);
        c = ones(size(input));
        x  = double(GT);

        xf = fft2(mean(x,3));
        
        % Scale image intensity
        zs = (sum(vec(x.*z)) / sum(vec(z.*z))) .* z;
        zf = fft2(mean(zs,3));

        % Estimate shift by registering deblurred to ground truth image
        [output Greg] = dftregistration(xf, zf, 1);
        shift = output(3:4);

        % Apply shift 
        cr = imshift(double(c), shift, 'same');
        zr = imshift(double(zs), shift, 'same');  
        xr = x.*cr;         
        psnr_ = metrix_mux(xr,zr,'PSNR');
        psnr_shift_list = [psnr_shift_list, psnr_];
        psnr_shift_list_total_frame = [psnr_shift_list_total_frame, psnr_];

        ssim_ = metrix_mux(xr,zr,'SSIM');
        ssim_shift_list = [ssim_shift_list, ssim_];
        ssim_shift_list_total_frame = [ssim_shift_list_total_frame, ssim_];

    end
    length(psnr_list_total_frame)
    psnr_list_total = [psnr_list_total, mean(psnr_list(:))];
    ssim_list_total = [ssim_list_total, mean(ssim_list(:))];
    psnr_shift_list_total = [psnr_shift_list_total, mean(psnr_shift_list(:))];
    ssim_shift_list_total = [ssim_shift_list_total, mean(ssim_shift_list(:))];
    
end

disp('psnr_shift_total_frame')
mean(psnr_shift_list_total_frame)

disp('ssim_shift_total_frame')
mean(ssim_shift_list_total_frame)

test_model
