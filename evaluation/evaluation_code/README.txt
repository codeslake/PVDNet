=================================================================
This README File explains how to change and call the
start_eval_image.m script to evaluate the (PSNR) scores of your
deblurred images.

ECCV 2012, Recording and playback of camera shake:
benchmarking blind deconvolution with a real-world database
Rolf Koehler, Michael Hirsch, Betty Mohler, Bernhard Schölkopf, 
Stefan Harmeling

corresponding author: rolf.koehler[ATAT]tuebingen.mpg.de
=================================================================


=================================================================
HOW TO SAVE AND NAME DEBLURRED IMAGES.
-----------------------------------------------------------------
  * Deblurred images should be saved in a lossless format, e.g. 'png'. 
  * Specify the path where you moved the evaluation scripts,
    the path where the deblurred images are saved to
    the name of the deblurred images and
    the img format, e.g. MYPATH = '~/EvalDeblur'
                     DEBLPATH = '~/deblurFolder'
                     DEBLNAME = 'Muller'
                     IMGEXT = 'png'
  * NOTE: The deblurred images should be named in the following way
     DEBLNAME{img_No}_{Kernel_No}.IMGEXT
     e.g. Muller3_8.png (for image 3, Kernel 8)


=================================================================
HOW TO CALL THE .m SCRIPT = HOW TO GET THE PSNR SCORE OF AN IMAGE
-----------------------------------------------------------------
  * copy the downloaded 48 GroundTruth$i_$j.mat files into the folder
    groundTruthMatFiles
  * in start_eval_image.m specify the path where you moved the evaluation scripts,
    the name of the deblurred images and the 
    img format, e.g. MYPATH = '~/EvalDeblur'
                     DEBLPATH = '~/deblurFolder'
                     DEBLNAME = 'Muller'
                     IMGEXT = 'png'
  * specify the metric you want to use (for the ECCV Paper only the 
    'PSNR' metric was used. For the journal version also other metrics
     will be used.
  * Define the image numbers which you want to evaluate
  * you can also define the images which you want to exclude, in case
    you do not want to compute the score for all 4 * 12 images


=================================================================
RESULTS
-----------------------------------------------------------------
Each deblurred image is compared with around 200 ground truth images. 
So in total you get for each deblurred image around 200 scores.
start_eval_image.m returns only a struct with the best score for each
deblurred image.


=================================================================
QUESTIONS?
-----------------------------------------------------------------
If any questions remained, we'll try to answer them:
rolf.koehler[ATAT]tuebingen.mpg.de


