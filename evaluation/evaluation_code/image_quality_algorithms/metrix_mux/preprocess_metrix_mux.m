%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%  FUNCTION:  preprocess_metrix_mux
%%%
%%%  INPUTS:    input_image         - input image data
%%%
%%%             metrix_indicator    - a series of letters (or a number) denoting
%%%                                   the metric to be used for this comparison;
%%%                                   type "help metrix_mux" to learn more about
%%%                                   what metrics are supported
%%%
%%%  OUTPUTS:   preprocessed_image  - preprocessed image data
%%%
%%%  CHANGES:   NONE
%%%
%%%  NOTES:     Range-checking is NOT performed because it is a relatively
%%%             expensive operation.  If no 'metrix_indicator' argument is
%%%             specified, ALL preprocessing measures are applied.  (Only
%%%             'IFC', 'VIF' and 'VSNR' require any padding.)  Though
%%%             future releases may address this issue differently, ALL input
%%%             images are converted to grayscale if they are not already
%%%             monochrome images.
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Author:    Matthew Gaubatz
%%%  Version:   1.1
%%%  Date:      04/15/2007
%%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Copyright (c) 2007 Visual Communications Lab, Cornell University
%%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Permission to use, copy, modify, distribute and sell this software     
%%%  and its documentation for any purpose is hereby granted without fee,   
%%%  provided that the above copyright notice appear in all copies and      
%%%  that both that copyright notice and this permission notice appear      
%%%  in supporting documentation.  VCL makes no representations about       
%%%  the suitability of this software for any purpose.                      
%%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  DISCLAIMER:
%%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  The code provided hereunder is provided as is without warranty
%%%  of any kind, either express or implied, including but not limited
%%%  to the implied warranties of merchantability and fitness for a
%%%  particular purpose.  The author(s) shall in no event be liable for
%%%  any damages whatsoever including direct, indirect, incidental,
%%%  consequential, loss of business profits or special damages.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function input_image = preprocess_metrix_mux( input_image, metrix_indicator )


%%%
%%% check if an image name was entered instead of an actual image;
%%% if so, try reading in the image
%%%
if isstr( input_image )
    try
        input_image = imread( input_image );
    catch
        error( sprintf('Error [preprocess_metrix_mux]:  Input argument ''%s'' does not correspond to a Matlab image or an image file.', input_image ) );
    end
end

%%%
%%% caste it to a double
%%%
if ~isa( input_image, 'double' )
    input_image = double( input_image );
end
%%%
%%% if necessary, make sure that there is just one color plane
%%%
[H,W,D] = size( input_image );


%%%
%%% MSE, PSNR can do color
%%%

if D ~= 1
    %%%
    %%% if the image has 3 color planes, assume that the planes
    %%% represent sRGB data and grab the luminance component
    %%% of the image
    %%%
    if D == 3
        input_image = 0.29900 * input_image(:,:,1) + 0.58700 * input_image(:,:,2) + 0.11400 * input_image(:,:,3);
    else
        error('Error [preprocess_metrix_mux]:  input image does not belong to a recognized color space.');
    end
end


%%%
%%% check to see if the image needs any padding and provide it if necessary
%%%
if  (nargin == 1) |...
    (strcmp( metrix_indicator, 'vif' ) ~= 0) |...
    (strcmp( metrix_indicator, 'ifc' ) ~= 0) |...
    (strcmp( metrix_indicator, 'vsnr' ) ~= 0)

    LCM_for_decomposition = 32;
    minimum_size_for_decomposition = 128;
        
    H_minimum = max( minimum_size_for_decomposition, LCM_for_decomposition*ceil(H/LCM_for_decomposition) );
    W_minimum = max( minimum_size_for_decomposition, LCM_for_decomposition*ceil(W/LCM_for_decomposition) );
    if (H ~= H_minimum) | (W ~= W_minimum)

        %%%
        %%% implement symmetric extension
        %%%
        padded_image = zeros(H_minimum,W_minimum);

        pad_pixels_top = round( (H_minimum-H)/2 );
        pad_pixels_bottom = H_minimum - H - pad_pixels_top;
        pad_pixels_left = round( (W_minimum - W)/2 );
        pad_pixels_right = W_minimum - W - pad_pixels_left;

        %%%
        %%% copy vertical then horizontal edge pixels
        %%%
        padded_image(pad_pixels_top+[1:H],1:pad_pixels_left) = input_image([1:H],1 + min(W-1,[pad_pixels_left:-1:1]) );
        padded_image(pad_pixels_top+[1:H],pad_pixels_left+W+1:end) = input_image([1:H], W - min(W-1,[1:pad_pixels_right]) );

        padded_image(1:pad_pixels_top,pad_pixels_left+[1:W]) = input_image(1 + min(H-1,[pad_pixels_top:-1:1]),[1:W] );
        padded_image(pad_pixels_top+H+1:end,pad_pixels_left+[1:W]) = input_image(H - min(H-1,[1:pad_pixels_bottom]),[1:W] );

        %%%
        %%% copy corners
        %%%
        padded_image(1:pad_pixels_top,1:pad_pixels_left) = input_image( min(H,2), min(W,2) );
        padded_image(pad_pixels_top+H+1:end,1:pad_pixels_left) = input_image( max(H-1,1), min(W,2) );
        padded_image(1:pad_pixels_top,pad_pixels_left+W+1:end) = input_image( min(H,2), max(W-1,1) );
        padded_image(pad_pixels_top+H+1:end,pad_pixels_left+W+1:end) = input_image( max(H-1,1), max(W-1,1) );

        %%%
        %%% copy main portion of image
        %%%
        padded_image(pad_pixels_top+[1:H],pad_pixels_left+[1:W]) = input_image;

        input_image = padded_image;
    end
    
end


preprocessed_image = input_image;
