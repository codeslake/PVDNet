%Bandpass contrast threshold function
%You may want to modify the default function based on your imaging system
%measurements
%Niranjan Damera-Venkata
% March 1998

function y=ctf(f_r)
s=size(f_r);
f_r=f_r(:);

y=1./(200*(2.6*(0.0192+0.114*(f_r)).*exp(-(0.114*(f_r)).^(1.1))));

y=reshape(y,s(1),s(2));
