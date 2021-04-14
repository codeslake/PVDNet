function y=dm(H,nfreq)
%DM    Distortion measure for linear frequency distortion 
%      RATIO = DM(DTF, NFREQ) computes the normalized CSF weighted
%      deviation of the DTF from unity in visual passband. 
%      NFREQ is the nyquist frequency
%      The user must compute the 2-D DTF(radial averaging not required)
%      for his/her system.
%    
%      Ref: N. Damera-Venkata, T. Kite, W. Geisler, B. Evans and A. Bovik, "Image
%      Quality Assessment Based on a Degradation Model", IEEE Trans. on Image 
%      Processing, Vol. 9, No. 4, Apr. 2000  (see pg 641 on computing DTF)
%
%      Ref: G. Arslan, M. Valliappan, and B. L. Evans, ``Quality Assessment of 
%      Compression Techniques for Synthetic Aperture Radar Images'', Proc. IEEE Int. 
%      Conf. on Image Processing, Oct. 25-28, 1999, vol. III, pp. 857-861, Kobe, Japan.
%
%     The version implemented here is from Arslan et. al.
%     This is a modified verion of the DM of Damera-Venkata et. al.

%     Function calls: WEIGHT_FREQ_CSF

%     Niranjan Damera-Venkata
%     August 2000


[wt, csf] = weight_freq_csf(abs(ones(size(H))-H),nfreq);
num = sum(sum(wt));
den = sum(sum(abs(csf))); 

y = (num/den);


