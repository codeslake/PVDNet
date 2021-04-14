function [psnr_mean, ssim_mean] = evaluation(test_model, folder_result, test_set, test_offset)
    if strcmp(test_set, 'DVD')
        folder_gt = fullfile(test_offset, 'test_DVD');
    elseif strcmp(test_set, 'nah')
        folder_gt = fullfile(test_offset, 'test_nah');
    end
    video_paths = dir(fullfile(folder_gt));
    video_paths = video_paths(3:end);

    % psnr_list_total_frame = [];
    % ssim_list_total_frame = [];
    psnr_shift_list_total_frame = [];
    ssim_shift_list_total_frame = [];

    %%
    cropsize = 16;
    for i = 1:length(video_paths)

        if strcmp(test_set, 'DVD')
            frame_path_GT = dir(fullfile(folder_gt, video_paths(i).name,'GT','*.jpg'));
        elseif strcmp(test_set, 'nah')
            frame_path_GT = dir(fullfile(folder_gt, video_paths(i).name,'sharp','*.png'));
        end

        frame_path_result = dir(fullfile(folder_result, video_paths(i).name, 'png', 'output', '*.png'));

        num = length(frame_path_result);
        parfor j = 2:num
            if strcmp(test_model, 'OVD')
                GT_idx = j + 1;
            else
                GT_idx = j;
            end

            GT = imread(fullfile(frame_path_GT(GT_idx).folder, frame_path_GT(GT_idx).name));
            if size(GT,2) ~= 1280
                GT = permute(GT,[2,1,3]);
            end

            input = imread(fullfile(frame_path_result(j).folder, frame_path_result(j).name));
            if size(input,2) ~= 1280
                input = permute(input,[2,1,3]);
            end        

            GT = GT(1+cropsize:end-cropsize,1+cropsize:end-cropsize,:);
            input = input(1+cropsize:end-cropsize,1+cropsize:end-cropsize,:);    

            %% matlab psnr/ssim (disabled)
    %         psnr_list_total_frame = [psnr_list_total_frame, psnr(im2double(GT),im2double(input))];
    %         ssim_list_total_frame = [ssim_list_total_frame, ssim(im2double(GT),im2double(input))];

            %% Koehler et al.
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
            psnr_shift_list_total_frame = [psnr_shift_list_total_frame, psnr_];

            ssim_ = metrix_mux(xr,zr,'SSIM');
            ssim_shift_list_total_frame = [ssim_shift_list_total_frame, ssim_];

            fprintf('[%s on %s] [%d/%d] [%d/%d] [gt_name: %s / input_name: %s] PSNR: %0.4f, SSIM: %0.4f\n', test_model, test_set, i, length(video_paths), j, num, frame_path_GT(GT_idx).name, frame_path_result(j).name, psnr_, ssim_);

        end   
    end
    psnr_mean = mean(psnr_shift_list_total_frame);
    ssim_mean = mean(ssim_shift_list_total_frame);
%     fprintf('[%s on %s]\n', test_model, test_set);
%     fprintf('PSNR (Koehler): %f\n', PSNR);
%     fprintf('SSIM (Koehler): %f\n', SSIM);
