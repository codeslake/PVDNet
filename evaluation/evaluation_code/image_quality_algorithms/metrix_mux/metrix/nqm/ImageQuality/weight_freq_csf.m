function [fimage,csf] = weight_freq_csf(orig,nfreq)
%WEIGHT_FREQ_CSF	Frequency domain weighting with CSF
%						[FIMAGE, CSF] = WEIGHT_FREQ_CSF(ORIG, NFREQ) computes
%						the result of weighting a 2-D centered frequency response 
%						ORIG with the CSF using a Nyquist frequency of NFREQ
%						Returns the wieighted result FIMAGE and the CSF that was used
%
%
%						Niranjan Damera-Venkata 
%						March 1998



if nargin==2
  nfreq=60;
end

[x,y]=size(orig);
[xplane,yplane]=meshgrid(-x/2+0.5:x/2-0.5);	% generate mesh
plane=(xplane+i*yplane)/x*2*nfreq;
radfreq=abs(plane);				% radial frequency
 
% According to (2), we modify the radial frequency according to angle.
% w is a symmetry parameter that gives approx. 3 dB down along the
% diagonals.
 
w=0.7;
s=(1-w)/2*cos(4*angle(plane))+(1+w)/2;
radfreq=radfreq./s;

csf=2.6*(0.0192+0.114*radfreq).*exp(-(0.114*radfreq).^1.1);
f=find(radfreq<7.8909); csf(f)=0.9809+zeros(size(f));

fimage = orig.*csf;

