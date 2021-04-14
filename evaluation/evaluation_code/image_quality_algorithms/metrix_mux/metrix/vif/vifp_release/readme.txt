% -----------COPYRIGHT NOTICE STARTS WITH THIS LINE------------
% Copyright (c) 2005 The University of Texas at Austin
% All rights reserved.
% 
% Permission is hereby granted, without written agreement and without license or royalty fees, to use, copy, 
% modify, and distribute this code (the source files) and its documentation for
% any purpose, provided that the copyright notice in its entirety appear in all copies of this code, and the 
% original source of this code, Laboratory for Image and Video Engineering (LIVE, http://live.ece.utexas.edu)
% at the University of Texas at Austin (UT Austin, 
% http://www.utexas.edu), is acknowledged in any publication that reports research using this code. The research
% is to be cited in the bibliography as:
% 
% H. R. Sheikh and A. C. Bovik, "Image Information and Visual Quality", IEEE Transactions on 
% Image Processing, (to appear).
% 
% IN NO EVENT SHALL THE UNIVERSITY OF TEXAS AT AUSTIN BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, 
% OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OF THIS DATABASE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF TEXAS
% AT AUSTIN HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
% 
% THE UNIVERSITY OF TEXAS AT AUSTIN SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE DATABASE PROVIDED HEREUNDER IS ON AN "AS IS" BASIS,
% AND THE UNIVERSITY OF TEXAS AT AUSTIN HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
% 
% -----------COPYRIGHT NOTICE ENDS WITH THIS LINE------------

This software release consists of a MULTISCALE PIXEL DOMAIN, SCALAR GSM implementation of the algorithm described in the paper:

H. R. Sheikh and A. C. Bovik, "Image Information and Visual Quality"., IEEE Transactions on Image Processing, (to appear).
Download manuscript draft from http://live.ece.utexas.edu in the Publications link.

THE PIXEL DOMAIN ALGORITHM IS NOT DESCRIBED IN THE PAPER. THIS IS A COMPUTATIONALLY SIMPLER
DERIVATIVE OF THE ALGORITHM PRESENTED IN THE PAPER


It consists of the following files:

readme.txt: this file
vifP_mscale.m: main function, call this to evaluate image quality

Input : (1) img1: The reference image as a matrix
        (2) img2: The distorted image (order is important)

Output: (1) VIF the visual information fidelity measure between the two images

Default Usage:
   Given 2 test images img1 and img2, whose dynamic range is 0-255

   vif = vifvec(img1, img2);

Advanced Usage:
   Users may want to modify the parameters in the code. 
   (1) Modify sigma_nsq to find tune for your image dataset.


Please read the paper for more details on interpretation of the results.
Email comments and bugfixes to hamid.sheikh@ieee.org