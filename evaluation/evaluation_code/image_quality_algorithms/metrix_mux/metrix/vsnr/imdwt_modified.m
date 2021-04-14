%%%MM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%MM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%MM%%% IMDWT, Modified Version
%%%MM%%%
%%%MM%%% The author of this modified version is with the Visual 
%%%MM%%% Communications Laboratory, in department of Electrical and 
%%%MM%%% Computer Engineering at Cornell University.  The original 
%%%MM%%% code was written by Damon Chandler at Cornell University. All of
%%%MM%%% the information and documentation provided with the original 
%%%MM%%% code is included below.  For more information, see the following
%%%MM%%% website:
%%%MM%%% 
%%%MM%%% http://foulard.ece.cornell.edu/dmc27/vsnr/vsnr.html
%%%MM%%%
%%%MM%%% This version of a two-dimensional 9/7 wavelet decomposition will
%%%MM%%% be invoked if the "compile_metric_vsnr" command cannot 
%%%MM%%% successfully build a MEX version of the function.  Currently,
%%%MM%%% MEX support is only provided for Windows-based platforms.
%%%MM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%MM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%MM%%  Author:    Matthew Gaubatz
%%%MM%%  Version:   1.0
%%%MM%%  Date:      01/05/2007
%%%MM%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%MM%%  Copyright (c) 2007 Visual Communications Lab, Cornell University 
%%%MM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%MM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [bands] = imdwt(img, nlevels)
%IMDWT Forward discrete wavelet transform of an image.
%  [BANDS] = IMDWT(IMG, NLEVELS) returns the subbands of a discrete
%  wavelet transform of the image IMG using the 9/7 biorthogonal 
%  filters.  The number of decomposition levels is specified via the
%  parameter NLEVELS (default = 5).
%%%MM%%%
%%%MM%%% [BEGIN CHANGE]
%%%MM%%%
%%%MM%%% only the instructions remain the same in this routine; while the
%%%MM%%% original 'imdwt.m' routine simply returned an error indicating
%%%MM%%% that the MEX file should be built, this version simply
%%%MM%%% computes a 5-level 9/7 wavelet transform
%%%MM%%%

%%%MM%%%
%%%MM%%% compute transform
%%%MM%%%
img = dwt2d(img, nlevels);

%%%MM%%%
%%%MM%%% save bands as objects
%%%MM%%%
[H,W] = size(img);
bands = cell(5,1);
scale_cell = cell(3,1);

for scale = 1:nlevels

  scale_cell{1} = img( 1:H/2, W/2+1:W );
  scale_cell{2} = img( H/2+1:H, 1:W/2 );
  scale_cell{3} = img( H/2+1:H, W/2+1:W );
  H = H / 2;
  W = W / 2;

  bands{scale} = scale_cell;

end

scale_cell{4} = img( 1:H, 1:W );
bands{nlevels} = scale_cell;


%%%MM%%%
%%%MM%%% comment out previous error message
%%%MM%%%
%%%MM%%% s = 'Please compile the mex version of this function.';
%%%MM%%% s = strcat(s, ' See the file "imdwt_cpp/compile_imdwt.m" for info.');
%%%MM%%% error(s);

%%%MM%%%
%%%MM%%% [END CHANGE]
%%%MM%%%
