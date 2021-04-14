
% -------------------------------------------------------------------
% Brief examples of using the VSNR() function
% -------------------------------------------------------------------

% load the original image
src_img = double(imread('horse.bmp'));
% load two distorted images
dst_img_1 = double(imread('horse.JP2.bmp'));
dst_img_2 = double(imread('horse.NOZ.bmp'));

tic
% compute the VSNR for one of the distorted images
vsnr(src_img, dst_img_1)
toc

tic
% compute the VSNR for the other distorted image [here, using the
% fast cache option by specifying -1 as the source image; this way,
% data regarding the source image don't have to be recomputed,
% rather, it will be recycled from the previous call to vsnr()]
vsnr(-1, dst_img_2)
toc

tic
% example of doubling the viewing distance
viewing_params.v = 19.1 * 2;
vsnr(src_img, dst_img_2, -1, viewing_params)
toc
