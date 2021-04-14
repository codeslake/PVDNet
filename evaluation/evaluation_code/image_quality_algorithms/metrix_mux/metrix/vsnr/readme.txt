
This package contains a beta MATLAB version of the VSNR function from
the paper "VSNR: A Wavelet-Based Visual Signal-to-Noise Ratio for 
Natural Images," D. M. Chandler and S. S. Hemami, published in the IEEE 
Transactions on Image Processing, September 2007.

The included files are as follows:

o  The function vsnr.m contains the source code of the VSNR() function.

o  The script vsnr_demo.m demonstrates how to compute the VSNR for the 
provided demo images (horse.bmp, horse.JP2.bmp, and horse.NOZ.bmp).

o  The file imdwt.dll is a Windows mex file version of the function
IMDWT(), which performs the forward discrete wavelet transform.  If 
this this mex file does not work with your version of MATLAB, please 
run the script compile_imdwt.m in the imdwt_cpp directory to create a 
compatible mex file from the provided C++ source code.

o  The directory imdwt_cpp contains the C++ source code for the IMDWT() 
function.  The IMDWT() function is required by VSNR() to compute the 
DWTs of the images.

Please contact Damon at damon.chandler@okstate.edu for questions and
other inquiries.

Cheers,
Damon
