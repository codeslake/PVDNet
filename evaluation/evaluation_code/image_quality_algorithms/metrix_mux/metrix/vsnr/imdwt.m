
function [bands] = imdwt(img, nlevels)
%IMDWT Forward discrete wavelet transform of an image.
%  [BANDS] = IMDWT(IMG, NLEVELS) returns the subbands of a discrete
%  wavelet transform of the image IMG using the 9/7 biorthogonal 
%  filters.  The number of decomposition levels is specified via the
%  parameter NLEVELS (default = 5).

s = 'Please compile the mex version of this function.';
s = strcat(s, ' See the file "imdwt_cpp/compile_imdwt.m" for info.');
error(s);
