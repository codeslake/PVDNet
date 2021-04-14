%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%  FUNCTION:  mssim_index
%%%
%%%  INPUTS:    img1                - original image data 
%%%
%%%             img2                - modified image data to be compared with
%%%                                   original image
%%%
%%%             nlevs               - number of levels for analysis 
%%%                                   (future parameter, currently only nlevs=5 
%%%                                   is supported)
%%%
%%%             K                   - see ssim_index
%%%
%%%             lpf                 - impulse response of low-pass filter to use
%%%                                   (defaults to 9/7 biorthogonal wavelet 
%%%                                   filters)
%%%
%%%  OUTPUTS:   mssim               - mssim value
%%%
%%%             comp                - vector containing mssim components as
%%%                                   [mean, contrast, cross-correlation]
%%%
%%%             detail              - vector containing mssim components at EACH
%%%                                   scale (same structure as comp)
%%%
%%%  CHANGES:   NONE
%%%             
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Author:    David Rouse
%%%  Version:   1.0
%%%  Date:      01/05/2007
%%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Copyright (c) 2007 Visual Communications Lab, Cornell University
%%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Permission to use, copy, modify, distribute and sell this software
%%%  and its documentation for any purpose is hereby granted without fee,
%%%  provided that the above copyright notice appear in all copies and
%%%  that both that copyright notice and this permission notice appear
%%%  in supporting documentation.  VCL makes no representations about
%%%  the suitability of this software for any purpose.
%%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  DISCLAIMER:
%%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  The code provided hereunder is provided as is without warranty
%%%  of any kind, either express or implied, including but not limited
%%%  to the implied warranties of merchantability and fitness for a
%%%  particular purpose.  The author(s) shall in no event be liable for
%%%  any damages whatsoever including direct, indirect, incidental,
%%%  consequential, loss of business profits or special damages.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [mssim, comp, detail] = mssim_index(img1, img2, nlevs,K,lpf)
% Multi-scale SSIM
% No need to specify first or second image as original and distorted
%  Input:
%   img1 - first image
%   img2 - second image
%
%  Output:
%   mssim - mssim value
%   comp - vector containing mssim components as
%           [mean, contrast, cross-correlation]
%   detail - vector containing mssim components at EACH scale (same
%   structure as comp)

nlevs = 5;

try
    K = K;
catch
    % Default SSIM parameters (assumes L=255)
    K = [0.01 0.03];
end

try
    lpf = lpf;
catch
    % Use Analysis Low Pass filter from Biorthogonal 9/7 Wavelet
    lod = [0.037828455507260; -0.023849465019560;  -0.110624404418440; ...
        0.377402855612830; 0.852698679008890;   0.377402855612830;  ...
        -0.110624404418440; -0.023849465019560; 0.037828455507260];
    lpf = lod*lod';
    lpf = lpf/sum(lpf(:));
end

img1 = double(img1);
img2 = double(img2);

window = fspecial('gaussian',11,1.5);
window = window/sum(sum(window));

ssim_v = zeros(nlevs,1);
ssim_r = zeros(nlevs,1);

% Scale 1 is the original image
[junk junk junk comp_ssim] = ssim_index_modified(img1,img2,K);
ssim_v(1) = comp_ssim(2);
ssim_r(1) = comp_ssim(3);

% Compute SSIM for scales 2 through 5
for s=1:nlevs-1    
    % Low Pass Filter
    img1 = imfilter(img1,lpf,'symmetric','same');
    img2 = imfilter(img2,lpf,'symmetric','same');
    
    img1 = img1(1:2:end,1:2:end);
    img2 = img2(1:2:end,1:2:end);

    [junk junk junk comp_ssim] = ssim_index_modified(img1,img2,K);
    ssim_m = comp_ssim(1);         % Mean Component only needed for scale 5
    ssim_v(s+1) = comp_ssim(2);
    ssim_r(s+1) = comp_ssim(3);   
end

alpha = 0.1333;
beta = [0.0448 0.2856 0.3001 0.2363 0.1333]';
gamma = [0.0448 0.2856 0.3001 0.2363 0.1333]';

comp = [ssim_m^alpha prod(ssim_v.^beta) prod(ssim_r.^gamma)];

detail = [ssim_m ssim_v' ssim_r'];

mssim = prod(comp);

return