function [res] = vsnr(src_img, dst_img, alpha, viewing_params)
%VSNR Visual signal-to-noise ratio for digital images.
%  [RES] = VSNR(SRC_IMG, DST_IMG) returns the visual signal-to-noise 
%  ratio for the distorted image DST_IMG relative to the original
%  image SRC_IMG.  The result is in dB in the range 0 - Inf.  If the
%  parameter SRC_IMG = -1, then data regarding the orignal image and
%  viewing conditions will be recycled from the previous call to VSNR
%  (see "Cache Option" below).
%
%  [RES] = VSNR(SRC_IMG, DST_IMG, ALPHA) allows for the additional
%  specification of the linear combination weight ALPHA (in the range
%  [0, 1]) which specifies the relative contributions of perceived
%  distortion contrast and disruption of global precedence toward the
%  total visual distortion.  By default, ALPHA = 0.04 (which uses 4% 
%  contribution from perceived distortion contrast, and 96%
%  contribution from disruption of global precedence).  Specifying a 
%  value of ALPHA = -1 will use the default (ALPHA = 0.04).
%
%  [RES] = VSNR(SRC_IMG, DST_IMG, ALPHA, VIEWING_PARAMS) allows for
%  additional specification of the viewing conditions and DWT options.  
%  The structure VIEWING_PARAMS contains the following data members 
%  which must be set prior to passing the structure to the VSNR 
%  function:
%
%    VIEWING_PARAMS.b = display device black-level offset 
%                       (default = 0, for 8-bit sRGB)
%    VIEWING_PARAMS.k = display device pixel-value-to-voltage gain 
%                       (default = 0.02874, for 8-bit sRGB)
%    VIEWING_PARAMS.g = display device pixel-value-to-voltage gain 
%                       (default = 2.2, for 8-bit sRGB)
%    VIEWING_PARAMS.r = display device resolution (pixels/inch) 
%                       (default = 96)
%    VIEWING_PARAMS.v = viewing distance (inches) 
%                       (default = 19.1)
%    VIEWING_PARAMS.num_levels = number of DWT levels 
%                       (default = 5)
%    VIEWING_PARAMS.filter_gains = DWT filter gains (may be all ones)
%                       (default = 2.^[1:num_levels])
%
%  Specifying a value of VIEWING_PARAMS = -1 will use the default 
%  initialization of VIEWING_PARAMS.
%
%  *** Cache Option ***
%  [RES] = VSNR(-1, DST_IMG) or [RES] = VSNR(-1, DST_IMG, ALPHA) 
%  informs the VSNR function that data corresponding to viewing 
%  conditions and analysis of the original image should not be 
%  computed; rather, these data should be reused from the previous 
%  call to VSNR.  This option is useful for measuring the VSNRs of 
%  various distorted versions of a single original image viewed under
%  the same viewing conditions.  Call VSNR(-1) [i.e., with only a 
%  single parameter of -1] to just clear the cache (no-op otherwise).
%
%  Requires function imdwt to perform the forward DWT of the images.
%  (See 'imdwt_cpp/compile_imdwt.m' for information on compiling a
%  max shared library from 'imdwt_cpp/imdwt.cpp'.)

%  Author: D. M. Chander
%  Copyright 1998-2007 Image Coding and Analysis Lab, Oklahoma State 
%  University, Stillwater, OK 74078 USA.
%  $Revision: BETA 1.02.0.0 $  $Date: 2007/10/04/ 15:00:00 $ 

% this global variable is used by all subfunctions
% and is later cleared by vsnr() before returning
global vsnr_data;

if (nargin == 1 & src_img == -1)
  clear global vsnr_data;
  res = -1;
  return;
end

if (nargin > 3 & src_img == -1)
  s = 'Ignoring specified viewing parameters under cache option.';
  s = strcat(s, ' Using cached parameters instead.');
  warning(s);
end

% default alpha
if (nargin < 3 | alpha == -1)
  alpha = 0.04;
end

if (src_img ~= -1)
  % default viewing parameters and DWT options
  if (nargin < 4 | ~isstruct(viewing_params))
    ok = 1
    % display device black-level offset (sRGB)
    vsnr_data.b = 0;
    % display device pixel-value-to-voltage gain (sRGB)
    vsnr_data.k = 0.02874;
    % display device gamma (sRGB)
    vsnr_data.g = 2.2;
    % display device resolution (pixels/inch)
    vsnr_data.r = 96;
    % viewing distance (inches)
    vsnr_data.v = 19.1;
    % number of DWT levels
    vsnr_data.num_levels = 5;
    % DWT filter gains (typically either as below, or all ones)
    vsnr_data.filter_gains = 2.^[1:vsnr_data.num_levels];
  else
    if (isfield(viewing_params, 'b'))
      vsnr_data.b = viewing_params.b;
    end
    if (isfield(viewing_params, 'k'))
      vsnr_data.k = viewing_params.k;
    end
    if (isfield(viewing_params, 'g'))
      vsnr_data.g = viewing_params.g;
    end
    if (isfield(viewing_params, 'r'))
      vsnr_data.r = viewing_params.r;
    end
    if (isfield(viewing_params, 'v'))
      vsnr_data.v = viewing_params.v;
    end
    if (isfield(viewing_params, 'num_levels'))
      vsnr_data.num_levels = viewing_params.num_levels;
    end
    if (isfield(viewing_params, 'filter_gains'))
      vsnr_data.filter_gains = viewing_params.filter_gains;
    else
      vsnr_data.filter_gains = 2.^[1:vsnr_data.num_levels];
    end
  end

  % spatial frequencies for DWT levels
  vsnr_data.fs = vsnr_data.r*vsnr_data.v*tan(pi/180) *...
    2.^-[1:vsnr_data.num_levels];

  % initialize the pixel-value-to-luminance lookup table
  pixel_vals = -255:255;
  vsnr_data.pix2lum_table =...
    (vsnr_data.b + vsnr_data.k*pixel_vals).^vsnr_data.g;

  % analyze the source image
  vsnr_data.src_img = src_img;
  clear src_img;
  analyze_src_img();
  
% attempting to reuse cached data, check...
elseif (~isfield(vsnr_data, 'src_img'))
  error('Invalid source image.  Cached data not available.');
end
  
% measure the actual CSNRs of the distorted image
csnrs_act = analyze_dst_img(dst_img);

if (csnrs_act == -1) % subthreshold distortions
  res = Inf;
else
  % if csnrs_act is a vector, this denotes the distortions 
  % are suprathreshold (visible)
  if (length(csnrs_act) == vsnr_data.num_levels)

    % compute the assumed best CSNRs for the given Ce
    csnrs_str = find_best_csnrs(vsnr_data.Ce);

    % convert the CSNRs to contrasts
    Ces_act = vsnr_data.Cis ./ csnrs_act;
    Ces_str = vsnr_data.Cis ./ csnrs_str;  

    % compute the distances
    d_gp = norm(Ces_str - Ces_act);
    d_pc = vsnr_data.Ce;
    d = alpha*d_pc + (1 - alpha)*d_gp/sqrt(2);
    
  % brightness-only difference      
  elseif (length(csnrs_act) == 1)    
    d = csnrs_act;
  end
  
  % compute the VSNR
  res = 20*log10(vsnr_data.Ci / d);
end

% clean up
clear vsnr_data.Ce;
clear vsnr_data.Ces;
% rest of vsnr_data is cached until a call to vsnr(-1)
%----------------------------------------------------------------------

function analyze_src_img()
global vsnr_data;
  
% compute some useful statistics about the original image
% mean pixel value
vsnr_data.mX = mean(vsnr_data.src_img(:));  
% mean luminance
src_img_lum = vsnr_data.pix2lum_table(vsnr_data.src_img(:) + 256);
vsnr_data.mL = mean(src_img_lum);
% total RMS image contrast
vsnr_data.Ci = std(src_img_lum, 1) / vsnr_data.mL;
% zeta value used to estimate image contrast at each scale
vsnr_data.zeta = vsnr_data.mL *...
  (vsnr_data.b + vsnr_data.k*vsnr_data.mX)^(1 - vsnr_data.g) /...
  (vsnr_data.k * vsnr_data.g);  

% compute the image contrast at each scale
vsnr_data.src_bands = imdwt(vsnr_data.src_img, vsnr_data.num_levels);
vsnr_data.Cis = zeros(1, vsnr_data.num_levels);
for s = 1:vsnr_data.num_levels
  for o = 1:3
    % estimate the contrast at scale s, orient o
    c = std(vsnr_data.src_bands{s}{o}(:), 1) /...
      (vsnr_data.zeta * vsnr_data.filter_gains(s));
    vsnr_data.Cis(s) = vsnr_data.Cis(s) + c*c;
  end
end
vsnr_data.Cis = sqrt(vsnr_data.Cis);

% compute the total distortion contrast threshold
ctsnrs = best_csnrs(0);  
CTes = vsnr_data.Cis ./ ctsnrs;
vsnr_data.CTe = norm(CTes);
%----------------------------------------------------------------------

function [res] = analyze_dst_img(dst_img)
global vsnr_data;

% compute the error image and its total RMS contrast
err_img = double(uint8(dst_img - vsnr_data.src_img + vsnr_data.mX));
err_img_lum = vsnr_data.pix2lum_table(err_img(:) + 256);
vsnr_data.Ce = std(err_img_lum, 1) / vsnr_data.mL;
 
% if the distortion contrast is suprathreshold
% (i.e., if the distortions are visible)...
if (vsnr_data.Ce > vsnr_data.CTe)
  % compute the distortion contrast at each scale
  err_bands = imdwt(err_img, vsnr_data.num_levels);
  vsnr_data.Ces = zeros(1, vsnr_data.num_levels);
  for s = 1:vsnr_data.num_levels
    for o = 1:3
      % estimate the contrast at scale s, orient o
      c = std(err_bands{s}{o}(:), 1) /...
        (vsnr_data.zeta * vsnr_data.filter_gains(s));
      vsnr_data.Ces(s) = vsnr_data.Ces(s) + c*c;
    end
  end
  vsnr_data.Ces = sqrt(vsnr_data.Ces);
  
  % compute the actual CSNRs
  res = vsnr_data.Cis ./ vsnr_data.Ces;
else
  lum_diff = abs(mean(err_img_lum) - vsnr_data.mL);
  if (lum_diff / vsnr_data.mL < 0.01)
    % distortions are subthreshold (undetectable)
    res = -1;
  else
    % punt to Weber's law for brightness-only differences
    res = 1.5;
    vsnr_data.Ci = 10^(vsnr_data.mL / lum_diff);
  end
end
%----------------------------------------------------------------------

function [res] = best_csnrs(v_idx)
global vsnr_data;

a0 = 59.8;
a1 = -0.1258; 
a2 = -0.1087;

b2 = (-1 - a2)*v_idx + a2;
b1 = (1 - a1)*v_idx + a1;
b0 = -a0*v_idx + a0;  

res = max(0, b0*(vsnr_data.fs.^(b2*log(vsnr_data.fs) + b1)));
%----------------------------------------------------------------------

function [res] = find_best_csnrs(Ce)
global vsnr_data;

save_Ce = Ce;
deltaCe = 0.01 * Ce;
v_idx_min = 0; v_idx_max = 1;

num_iters = 0;
while (num_iters < 32)
  v_idx = 0.5 * (v_idx_min + v_idx_max);
  if (num_iters > 0)
    Ce = save_Ce;
  end

  % compute the best CSNRs for the given visibility index
  csnrs = best_csnrs(v_idx);
  % compute the corresponding distortion contrast
  hat_Ce = norm(vsnr_data.Cis ./ csnrs);

  if (v_idx_min == v_idx_max)
    % punt
    break;
  end

  diffCe = hat_Ce - Ce;
  if (abs(diffCe) < deltaCe)
    % close enough
    break;
  elseif (diffCe < 0)
    % Ce too low
    v_idx_min = v_idx;
  else 
    % Ce too high
    v_idx_max = v_idx;
  end
end

res = csnrs;
%----------------------------------------------------------------------
