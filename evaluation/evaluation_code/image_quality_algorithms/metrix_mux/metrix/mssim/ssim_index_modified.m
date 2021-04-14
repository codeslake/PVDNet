function [ssim, ssim_map, map_obj, composite_mean_vec] = ssim_index_modified(img1, img2, K, window, L)
%%%MM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%MM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%MM%%% SSIM Index, Modified Version
%%%MM%%%
%%%MM%%% The authors of this modified version are with the Visual 
%%%MM%%% Communications Laboratory, in department of Electrical and 
%%%MM%%% Computer Engineering at Cornell University.  The original 
%%%MM%%% code was written by Zhou Wang at NYU. All of the information
%%%MM%%% and documentation provided with the original code is included
%%%MM%%% below.  For more information, see the following website:
%%%MM%%% 
%%%MM%%% http://www.ece.uwaterloo.ca/~z70wang/research/ssim/
%%%MM%%%
%%%MM%%% This version of the SSIM index computation routine is identical
%%%MM%%% to the original routine, except that it returns two additional
%%%MM%%% arguments:
%%%MM%%%
%%%MM%%% (1) 'map_obj', which has fields M, V and R which respectively
%%%MM%%%     represent the luminance, contrast and structure components
%%%MM%%%     used during the SSIM index computation, and
%%%MM%%%
%%%MM%%% (2) 'component_mean_vec', which contains the mean values of the
%%%MM%%%     of 'map_obj' fields.
%%%MM%%%
%%%MM%%% This routine is used to help compute the version of the MSSIM
%%%MM%%% index, a multi-scale version of the SSIM index, included with
%%%MM%%% this package.
%%%MM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%MM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%MM%%% Authors:   David Rouse and Matthew Gaubatz
%%%MM%%% Version:   1.0
%%%MM%%% Date:      01/05/2007
%%%MM%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%MM%%% Copyright (c) 2007 Visual Communications Lab, Cornell University 
%%%MM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%MM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%========================================================================
%SSIM Index, Version 1.0
%Copyright(c) 2003 Zhou Wang
%All Rights Reserved.
%
%The author is with Howard Hughes Medical Institute, and Laboratory
%for Computational Vision at Center for Neural Science and Courant
%Institute of Mathematical Sciences, New York University.
%
%----------------------------------------------------------------------
%Permission to use, copy, or modify this software and its documentation
%for educational and research purposes only and without fee is hereby
%granted, provided that this copyright notice and the original authors'
%names appear on all copies and supporting documentation. This program
%shall not be used, rewritten, or adapted as the basis of a commercial
%software or hardware product without first obtaining permission of the
%authors. The authors make no representations about the suitability of
%this software for any purpose. It is provided "as is" without express
%or implied warranty.
%----------------------------------------------------------------------
%
%This is an implementation of the algorithm for calculating the
%Structural SIMilarity (SSIM) index between two images. Please refer
%to the following paper:
%
%Z. Wang, A. C. Bovik, H. R. Sheikh, and E. P. Simoncelli, "Image
%quality assessment: From error visibility to structural similarity"
%IEEE Transactios on Image Processing, vol. 13, no. 4, pp.600-612,
%Apr. 2004.
%
%Kindly report any suggestions or corrections to zhouwang@ieee.org
%
%----------------------------------------------------------------------
%
%Input : (1) img1: the first image being compared
%        (2) img2: the second image being compared
%        (3) K: constants in the SSIM index formula (see the above
%            reference). defualt value: K = [0.01 0.03]
%        (4) window: local window for statistics (see the above
%            reference). default widnow is Gaussian given by
%            window = fspecial('gaussian', 11, 1.5);
%        (5) L: dynamic range of the images. default: L = 255
%
%Output: (1) mssim: the mean SSIM index value between 2 images.
%            If one of the images being compared is regarded as 
%            perfect quality, then mssim can be considered as the
%            quality measure of the other image.
%            If img1 = img2, then mssim = 1.
%        (2) ssim_map: the SSIM index map of the test image. The map
%            has a smaller size than the input images. The actual size:
%            size(img1) - size(window) + 1.
%
%Default Usage:
%   Given 2 test images img1 and img2, whose dynamic range is 0-255
%
%   [mssim ssim_map] = ssim_index(img1, img2);
%
%Advanced Usage:
%   User defined parameters. For example
%
%   K = [0.05 0.05];
%   window = ones(8);
%   L = 100;
%   [mssim ssim_map] = ssim_index(img1, img2, K, window, L);
%
%See the results:
%
%   mssim                        %Gives the mssim value
%   imshow(max(0, ssim_map).^4)  %Shows the SSIM index map
%
%========================================================================


if (nargin < 2 | nargin > 5)
   ssim_index = -Inf;
   ssim_map = -Inf;
   return;
end

if (size(img1) ~= size(img2))
   ssim_index = -Inf;
   ssim_map = -Inf;
   return;
end

[M N] = size(img1);

if (nargin == 2)
   if ((M < 11) | (N < 11))
	   ssim_index = -Inf;
	   ssim_map = -Inf;
      return
   end
   window = fspecial('gaussian', 11, 1.5);	%
   K(1) = 0.01;								      % default settings
   K(2) = 0.03;								      %
   L = 255;                                  %
end

if (nargin == 3)
   if ((M < 11) | (N < 11))
	   ssim_index = -Inf;
	   ssim_map = -Inf;
      return
   end
   window = fspecial('gaussian', 11, 1.5);
   L = 255;
   if (length(K) == 2)
      if (K(1) < 0 | K(2) < 0)
		   ssim_index = -Inf;
   		ssim_map = -Inf;
	   	return;
      end
   else
	   ssim_index = -Inf;
   	ssim_map = -Inf;
	   return;
   end
end

if (nargin == 4)
   [H W] = size(window);
   if ((H*W) < 4 | (H > M) | (W > N))
	   ssim_index = -Inf;
	   ssim_map = -Inf;
      return
   end
   L = 255;
   if (length(K) == 2)
      if (K(1) < 0 | K(2) < 0)
		   ssim_index = -Inf;
   		ssim_map = -Inf;
	   	return;
      end
   else
	   ssim_index = -Inf;
   	ssim_map = -Inf;
	   return;
   end
end

if (nargin == 5)
   [H W] = size(window);
   if ((H*W) < 4 | (H > M) | (W > N))
	   ssim_index = -Inf;
	   ssim_map = -Inf;
      return
   end
   if (length(K) == 2)
      if (K(1) < 0 | K(2) < 0)
		   ssim_index = -Inf;
   		ssim_map = -Inf;
	   	return;
      end
   else
	   ssim_index = -Inf;
   	ssim_map = -Inf;
	   return;
   end
end

C1 = (K(1)*L)^2;
C2 = (K(2)*L)^2;
window = window/sum(sum(window));
img1 = double(img1);
img2 = double(img2);

mu1   = filter2(window, img1, 'valid');
mu2   = filter2(window, img2, 'valid');
mu1_sq = mu1.*mu1;
mu2_sq = mu2.*mu2;
mu1_mu2 = mu1.*mu2;
sigma1_sq = filter2(window, img1.*img1, 'valid') - mu1_sq;
sigma2_sq = filter2(window, img2.*img2, 'valid') - mu2_sq;
sigma1 = real(sqrt(sigma1_sq));
sigma2 = real(sqrt(sigma2_sq));
sigma12 = filter2(window, img1.*img2, 'valid') - mu1_mu2;

if (C1 > 0 && C2 > 0)
   M = (2*mu1_mu2 + C1)./(mu1_sq + mu2_sq + C1);
   V = (2*sigma1.*sigma2 + C2)./(sigma1_sq + sigma2_sq + C2);
   R = (sigma12 + C2/2)./(sigma1.*sigma2+C2/2);
   ssim_map = M.*V.*R;
else
   ssim_ln = 2*mu1_mu2;
   ssim_ld = mu1_sq + mu2_sq;
   M = ones(size(mu1));
   index_l = (ssim_ld>0);
   M(index_l) = ssim_ln(index_l)./ssim_ld(index_l);
   
   ssim_cn = 2*sigma1.*sigma2;
   ssim_cd = sigma1_sq + sigma2_sq;
   V = ones(size(mu1));
   index_c = (ssim_cd>0);
   V(index_c) = ssim_cn(index_c)./ssim_cd(index_c);
   
   ssim_sn = sigma12;
   ssim_sd = sigma1.*sigma2;
   R = ones(size(mu1));
   index1 = sigma1>0;
   index2 = sigma2>0;
   index_s = (index1.*index2>0);
   R(index_s) = ssim_sn(index_s)./ssim_sd(index_s);
   index_s = (index1.*not(index2)>0);
   R(index_s) = 0;
   index_s = (not(index1).*index2>0);
   R(index_s) = 0;
   
   ssim_map = M.*V.*R;
end

ssim = mean2(ssim_map);

%%%MM%%%
%%%MM%%% [BEGIN CHANGE]
%%%MM%%%

%%%MM%%%
%%%MM%%% create per-component maps
%%%MM%%%
map_obj.M = M;
map_obj.V = V;
map_obj.R = R;

%%%MM%%%
%%%MM%%% compute per-component map mean values
%%%MM%%%
composite_mean_vec = [mean2(M) mean2(V) mean2(R)];

%%%MM%%%
%%%MM%%% [END CHANGE]
%%%MM%%%

return