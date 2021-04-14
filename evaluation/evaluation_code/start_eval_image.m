% =================================================================
% DEFINE IMGPATH, DEBLNAME, IMGTEXT AND metric
% -----------------------------------------------------------------
MYPATH = ['/is/ei/rolfk/cpr/prj/camera_shake_benchmark/code/' ...
                 'eval_deblur_img'];
DEBLPATH = '/agbs/cpr/prj/camera_shake_benchmark/benchmark/Deblurred/Hirsch';
DEBLNAME = 'Deblurred';
IMGEXT = 'png';

% -----------------------------------------------------------------
% DEFINE METRIC: available metrics: 'MSE','MSSIM','VIF','IFC','PSNR','MAD'
% -----------------------------------------------------------------
metric = {'PSNR'};

% =================================================================
% DEFINE image Number (1 to 4) and Kernel Number (1 to 12) of
% deblurred images, which shall be assigned a score
% -----------------------------------------------------------------
imgNo = 1:4;
kernNo = 1:12;

% do not calculate the score for following images [img, kernel; img
% kernel]
% exclude = [1 1; 1 2; 1 3; 1 4; 1 5; 1 6];
exclude = [];
% =================================================================
% run the evaluation script with all ground truth images
% -----------------------------------------------------------------
cd(MYPATH)

for iM = 1 : length(metric)
  for iImg = imgNo
    for iKern = kernNo
      if ~isempty(intersect([iImg iKern],exclude,'rows'))
        continue
      end
      
      metricNow = metric{iM};
      deblurred = imread(sprintf('%s/%s%d_%d.%s',DEBLPATH,DEBLNAME,iImg,iKern,IMGEXT));
      scores = eval_image(deblurred,iImg,iKern,metricNow);
     
      switch metricNow
        case 'MSE'
          DeblurScore.MSE(iImg,iKern) = ...
              get_best_metric_value2(scores.MSE,'MSE',iImg,iKern);
        case 'MSSIM'
           DeblurScore.MSSIM(iImg,iKern) = ...
              get_best_metric_value2(scores.MSSIM,'MSSIM',iImg,iKern);
        case 'VIF'
          DeblurScore.VIF(iImg,iKern) = ...
              get_best_metric_value2(scores.VIF,'VIF',iImg,iKern);
        case 'IFC'
           DeblurScore.IFC(iImg,iKern) = ...
              get_best_metric_value2(scores.IFC,'IFC',iImg,iKern);
        case 'PSNR'
          DeblurScore.PSNR(iImg,iKern) = ...
              get_best_metric_value2(scores.PSNR,'PSNR',iImg,iKern);
        case 'MAD'
           DeblurScore.MAD(iImg,iKern) = ...
              get_best_metric_value2(scores.MAD,'MAD',iImg,iKern);
      end
               
    end
  end
end



% =================================================================
% function dependencies
% -----------------------------------------------------------------
% start_eval_image.m
%   *eval_image.m
%     -dftregistration.m
%     -imshift.m
%     -metrix_mux
%     -MAD_index
%       + myrgb2gray
%   *get_best_metric_value2
