function ratio=wsnr(orig, dith, nfreq)
%%%MM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%MM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%MM%%% NQM, Modified Version
%%%MM%%%
%%%MM%%% The author of this modified version is with the Visual 
%%%MM%%% Communications Laboratory, in department of Electrical and 
%%%MM%%% Computer Engineering at Cornell University.  The original 
%%%MM%%% code was written by Thomas Kite at U.T. Austin. All of the
%%%MM%%% information and documentation provided with the original code is
%%%MM%%% included below.  
%%%MM%%% 
%%%MM%%% This version of the WSNR computation routine is identical to the
%%%MM%%% original routine, except that it can handle non-square images.
%%%MM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%MM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%MM%%% Author:    Matthew Gaubatz
%%%MM%%% Version:   1.0
%%%MM%%% Date:      04/15/2007
%%%MM%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%MM%%% Copyright (c) 2007 Visual Communications Lab, Cornell University 
%%%MM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%MM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%WSNR  Weighted signal to noise ratio.
%	RATIO = WSNR(IM1, IM2, MAXFREQ) computes the weighted signal to noise
%	ratio of IM2 with respect to IM1 and returns the result in dB.
%	A weighting appropriate to the human visual system, as proposed
%	by Mannos and Sakrison (1) and modified by Mitsa and Varkur (2),
%	is used.  MAXFREQ specifies the spatial frequency in cycles per
% 	degree that corresponds to the Nyquist frequency in the x-direction.
%	If MAXFREQ is omitted, it defaults to 60 cyc/deg.
%
%	Refs: (1) J. Mannos and D. Sakrison, "The effects of a visual
%	fidelity criterion on the encoding of images", IEEE Trans. Inf.
%	Theory, IT-20(4), pp. 525-535, July 1974.
%
%	(2) T. Mitsa and K. Varkur, "Evaluation of contrast sensitivity
%	functions for the formulation of quality measures incorporated
%	in halftoning algorithms", ICASSP '93-V, pp. 301-304.
%
%	See also SNR, PSNR, TSNR, SNRVSF.
 
%       T Kite April 1997, January 1998
 
if nargin==2
  nfreq=60;
end

[x,y]=size(orig);
%%%MM%%%
%%%MM%%% [BEGIN CHANGE]
%%%MM%%%
%%%MM%%%[xplane,yplane]=meshgrid(-x/2+0.5:x/2-0.5);	% generate mesh
[xplane,yplane]=meshgrid(-y/2+0.5:y/2-0.5,-x/2+0.5:x/2-0.5);	% generate mesh
%%%MM%%%
%%%MM%%% [END CHANGE]
%%%MM%%%
plane=(xplane+i*yplane)/x*2*nfreq;
radfreq=abs(plane);				% radial frequency
 
% According to (2), we modify the radial frequency according to angle.
% w is a symmetry parameter that gives approx. 3 dB down along the
% diagonals.
 
w=0.7;
s=(1-w)/2*cos(4*angle(plane))+(1+w)/2;
radfreq=radfreq./s;

% Now generate the CSF

csf=2.6*(0.0192+0.114*radfreq).*exp(-(0.114*radfreq).^1.1);
f=find(radfreq<7.8909); csf(f)=0.9809+zeros(size(f));
 
% Find weighted SNR in frequency domain.  Note that, because we are not
% weighting the signal, we compute signal power in the spatial domain.
% This requires us to multiply by the image size in pixels to get the
% signal power in the freqency domain for division.

err=orig-dith;
%err_wt=fft2(err).*csf;				% weighted error spectrum
err_wt=fftshift(fft2(err)).*csf;
im=fft2(orig);

mse=sum(sum(err_wt.*conj(err_wt)));		% weighted error power
mss=sum(sum(im.*conj(im)));			% signal power
ratio=10*log10(mss/mse);			% compute SNR



