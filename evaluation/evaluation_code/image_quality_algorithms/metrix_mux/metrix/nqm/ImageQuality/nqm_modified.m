function y=nqm(O,I,VA,N)
%%%MM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%MM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%MM%%% NQM, Modified Version
%%%MM%%%
%%%MM%%% The author of this modified version is with the Visual 
%%%MM%%% Communications Laboratory, in department of Electrical and 
%%%MM%%% Computer Engineering at Cornell University.  The original 
%%%MM%%% code was written by Niranjan Damera-Venkata at U.T. Austin. All
%%%MM%%% of the information and documentation provided with the original 
%%%MM%%% code is included below.  
%%%MM%%% 
%%%MM%%% This version of the NQM computation routine is identical to the
%%%MM%%% original routine, except that it can handle non-square images.
%%%MM%%% The functions 'cmaskn' and 'gthresh' are no longer called; 
%%%MM%%% instead, locally defined versions of the same routines, extended
%%%MM%%% for the same purpose, are invoked.
%%%MM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%MM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%MM%%% Author:    Matthew Gaubatz
%%%MM%%% Version:   1.0
%%%MM%%% Date:      04/15/2007
%%%MM%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%MM%%% Copyright (c) 2007 Visual Communications Lab, Cornell University 
%%%MM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%MM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%NQM   Nonlinear Weighted Signal to noise ratio for additive noise.
%      RATIO = NQM(MOD_RES,RES,ANGLE, DIM) computes the nonlinear weighted signal to
%      noise ratio of the restored image MOD_RES with respect to the model
%      restored image MOD_RES and returns the result in dB.
%      ANGLE is the viewing angle. DIM is the [DIM DIM] dimension of the image 
%
%      Note that NQM is a measure of additive noise only. The model restored 
%      image is assumed to have the same freq. distortion as the restored image.  
%
%      Function calls: CTF, CMASKN, GTHRESH
%
%      Ref: N. Damera-Venkata, T. Kite, W. Geisler, B. Evans and A. Bovik, "Image
%      Quality Assessment Based on a Degradation Model", IEEE Trans. on Image 
%      Processing, Vol. 9, No. 4, Apr. 2000  
%
%      Ref: E. Peli, "Contrast in Complex Images", Journal of the Optical
%      Society of America A, Vol. 7, No. 10, Oct. 1990
%
%      See also CSFMOD, CSF, PSNR, WSNR
%
%      Niranjan Damera-Venkata March 1998 
 

[x,y]=size(O);

%%%MM%%%
%%%MM%%% [BEGIN CHANGE]
%%%MM%%%
%%%MM%%%[xplane,yplane]=meshgrid(-x/2:x/2-1);
[xplane,yplane]=meshgrid(-y/2:y/2-1,-x/2:x/2-1);
%%%MM%%%
%%%MM%%% [END CHANGE]
%%%MM%%%
plane=(xplane+i*yplane);
r=abs(plane);

FO=fft2(O);
FI=fft2(I);


%%%%%%%%%%% Decompose image with cosine log filter bank %%%%%%%%%%%%%%%%
G_0=0.5*(1+cos(pi*log2((r+2).*([r+2<=4].*[r+2>=1])+4.*(~([r+2<=4].*[r+2>=1])) )-pi));

G_1=0.5*(1+cos(pi*log2(r.*([r<=4].*[r>=1])+4.*(~([r<=4].*[r>=1])) )-pi));

G_2=0.5*(1+cos(pi*log2(r.*([r>=2].* [r<=8])+.5.*(~([r>=2].* [r<=8])))));

G_3=0.5*(1+cos(pi*log2(r.*([r>=4].*[r<=16])+4.*(~([r>=4].*[r<=16])) )-pi));

G_4=0.5*(1+cos(pi*log2(r.*([r>=8].* [r<=32])+.5.*(~([r>=8].* [r<=32])))));

G_5=0.5*(1+cos(pi*log2(r.*([r>=16].*[r<=64])+4.*(~([r>=16].*[r<=64])) )-pi));


GS_0=fftshift(G_0);
GS_1=fftshift(G_1);
GS_2=fftshift(G_2);
GS_3=fftshift(G_3);
GS_4=fftshift(G_4);
GS_5=fftshift(G_5);


L_0=((GS_0).*FO); LI_0=(GS_0.*FI);

l_0=real(ifft2(L_0));li_0=real(ifft2(LI_0));

A_1=GS_1.*FO; AI_1=(GS_1.*FI); 

a_1=real(ifft2(A_1));ai_1=real(ifft2(AI_1));

A_2=GS_2.*FO;AI_2=GS_2.*FI;

a_2=real(ifft2(A_2));ai_2=real(ifft2(AI_2));

A_3=GS_3.*FO;AI_3=GS_3.*FI;

a_3=real(ifft2(A_3));ai_3=real(ifft2(AI_3));

A_4=GS_4.*FO;AI_4=GS_4.*FI;

a_4=real(ifft2(A_4));ai_4=real(ifft2(AI_4));

A_5=GS_5.*FO;AI_5=GS_5.*FI;

a_5=real(ifft2(A_5));ai_5=real(ifft2(AI_5));


clear FO;
clear FI;

clear G_0;
clear G_1;
clear G_2;
clear G_3;
clear G_4;
clear G_5;


clear GS_0;
clear GS_1;
clear GS_2;
clear GS_3;
clear GS_4;
clear GS_5;

%%%%%%%%%%%%%%%%%%%%%Compute contrast images%%%%%%%%%%%%%%%%%%%
c1=((a_1./(l_0)));
c2=(a_2./(l_0+a_1));
c3=(a_3./(l_0+a_1+a_2));
c4=(a_4./(l_0+a_1+a_2+a_3));
c5=(a_5./(l_0+a_1+a_2+a_3+a_4));

ci1=(ai_1./(li_0));
ci2=(ai_2./(li_0+ai_1));
ci3=(ai_3./(li_0+ai_1+ai_2));
ci4=(ai_4./(li_0+ai_1+ai_2+ai_3));
ci5=(ai_5./(li_0+ai_1+ai_2+ai_3+ai_4));


%%%%%%%%%%%%%%%%%%%%%%Detection Thresholds%%%%%%%%%%%%%%%%%%%%%%

d1=ctf(2/VA);
d2=ctf(4/VA);
d3=ctf(8/VA);
d4=ctf(16/VA);
d5=ctf(32/VA);

%%%%%%%%%%%%%%%%%%Account for suprathrshold effects (See Bradley and Ozhawa)%%%%
%%%MM%%%
%%%MM%%% [BEGIN CHANGE]
%%%MM%%%
%%%MM%%% the following change replaces two external function with locally
%%%MM%%% defined versions capable of handling non-square images
%%%MM%%%
%%%MM%%% ai_1=cmaskn(c1,ci1,a_1,ai_1,1,N);
%%%MM%%% ai_2=cmaskn(c2,ci2,a_2,ai_2,2,N);
%%%MM%%% ai_3=cmaskn(c3,ci3,a_3,ai_3,3,N);
%%%MM%%% ai_4=cmaskn(c4,ci4,a_4,ai_4,4,N);
%%%MM%%% ai_5=cmaskn(c5,ci5,a_5,ai_5,5,N);
ai_1=cmaskn_modified(c1,ci1,a_1,ai_1,1);
ai_2=cmaskn_modified(c2,ci2,a_2,ai_2,2);
ai_3=cmaskn_modified(c3,ci3,a_3,ai_3,3);
ai_4=cmaskn_modified(c4,ci4,a_4,ai_4,4);
ai_5=cmaskn_modified(c5,ci5,a_5,ai_5,5);

%%%%%%%%%%Apply detection thresholds%%%%%%%%%%%%%%%%%%%%%%
%%%MM%%% A_1=gthresh(c1,d1,a_1,N);AI_1=gthresh(ci1,d1,ai_1,N);
%%%MM%%% A_2=gthresh(c2,d2,a_2,N);AI_2=gthresh(ci2,d2,ai_2,N);
%%%MM%%% A_3=gthresh(c3,d3,a_3,N);AI_3=gthresh(ci3,d3,ai_3,N);
%%%MM%%% A_4=gthresh(c4,d4,a_4,N);AI_4=gthresh(ci4,d4,ai_4,N);
%%%MM%%% A_5=gthresh(c5,d5,a_5,N);AI_5=gthresh(ci5,d5,ai_5,N);
A_1=gthresh_modified(c1,d1,a_1);AI_1=gthresh_modified(ci1,d1,ai_1);
A_2=gthresh_modified(c2,d2,a_2);AI_2=gthresh_modified(ci2,d2,ai_2);
A_3=gthresh_modified(c3,d3,a_3);AI_3=gthresh_modified(ci3,d3,ai_3);
A_4=gthresh_modified(c4,d4,a_4);AI_4=gthresh_modified(ci4,d4,ai_4);
A_5=gthresh_modified(c5,d5,a_5);AI_5=gthresh_modified(ci5,d5,ai_5);

%%%MM%%%
%%%MM%%% [END CHANGE]
%%%MM%%%

%%%%%%%%reconstruct images%%%%%%%%%%%%%%%%%%%
y1=(A_1+A_2+A_3+A_4+A_5);
y2=(AI_1+AI_2+AI_3+AI_4+AI_5);

%%%%%%%%%%%%%%%compute SNR%%%%%%%%%%%%%%%%%%%%
square_err=(y1-y2).*(y1-y2);
np=sum(sum(square_err));

sp=sum(sum(y1.^2));

y=10*log10(sp/np);


%%%MM%%%
%%%MM%%% [BEGIN CHANGE]
%%%MM%%%
%%%MM%%%
%%%MM%%% the following two helper functions were added to help this
%%%MM%%% function process non-square images
%%%MM%%%
function y=cmaskn_modified(c,ci,a,ai,i)
[H,W] = size(c);
    
c=c(:);
ci=ci(:);

t=find(abs(ci)>1);
ci(t)=1;
ai=ai(:);
a=a(:);

ct=ctf(i);
T=ct*(.86*((c/ct)-1)+.3);

a1=find( (abs(ci-c)-T)<0);

ai(a1)=a(a1);

y=reshape(ai,H,W);

function y=gthresh_modified(x,T,z)

[H,W] = size(x);

x=x(:);
z=z(:);
a=find(abs(x)<T);

z(a)=zeros(size(a));

y=reshape(z,H,W);

%%%MM%%%
%%%MM%%% [END CHANGE]
%%%MM%%%
