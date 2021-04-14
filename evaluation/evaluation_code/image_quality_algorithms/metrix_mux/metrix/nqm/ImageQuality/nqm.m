function y=nqm(O,I,VA,N)
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

[xplane,yplane]=meshgrid(-x/2:x/2-1);
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
ai_1=cmaskn(c1,ci1,a_1,ai_1,1,N);
ai_2=cmaskn(c2,ci2,a_2,ai_2,2,N);
ai_3=cmaskn(c3,ci3,a_3,ai_3,3,N);
ai_4=cmaskn(c4,ci4,a_4,ai_4,4,N);
ai_5=cmaskn(c5,ci5,a_5,ai_5,5,N);

%%%%%%%%%%Apply detection thresholds%%%%%%%%%%%%%%%%%%%%%%
A_1=gthresh(c1,d1,a_1,N);AI_1=gthresh(ci1,d1,ai_1,N);
A_2=gthresh(c2,d2,a_2,N);AI_2=gthresh(ci2,d2,ai_2,N);
A_3=gthresh(c3,d3,a_3,N);AI_3=gthresh(ci3,d3,ai_3,N);
A_4=gthresh(c4,d4,a_4,N);AI_4=gthresh(ci4,d4,ai_4,N);
A_5=gthresh(c5,d5,a_5,N);AI_5=gthresh(ci5,d5,ai_5,N);


%%%%%%%%reconstruct images%%%%%%%%%%%%%%%%%%%
y1=(A_1+A_2+A_3+A_4+A_5);
y2=(AI_1+AI_2+AI_3+AI_4+AI_5);

%%%%%%%%%%%%%%%compute SNR%%%%%%%%%%%%%%%%%%%%
square_err=(y1-y2).*(y1-y2);
np=sum(sum(square_err));

sp=sum(sum(y1.^2));

y=10*log10(sp/np);


