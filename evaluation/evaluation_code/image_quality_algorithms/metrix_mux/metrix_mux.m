%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%  FUNCTION:  metrix_mux
%%%
%%%  INPUTS:    reference_image     - original image data 
%%%
%%%             query_image         - modified image data to be compared with
%%%                                   original image
%%%
%%%             metrix_indicator    - a series of letters (or a number) denoting
%%%                                   the assement algorithm to be used for this 
%%%                                   comparison; names (and corresponding
%%%                                   numbers of supported algorithms are given
%%%                                   below.
%%%  
%%%  OUTPUTS:   metrix_value        - value computed by the selected algorithm
%%%
%%%  CHANGES:   NONE
%%%
%%%  NOTES:     This routine is the generic gateway to all the quality 
%%%             assessment algorithms included in the MeTriX MuX package.  The
%%%             API is simple; it requires an input reference image, an input
%%%             query image to be compared with the reference image, and an
%%%             algorithm name.  A list of all supported metrics is given here:
%%%
%%%             algorithm                       indicator string indicator value
%%%             ---------------------------     ---------------- ---------------
%%%             mean-squared error              'MSE'            1
%%%             peak signal-to-noise ratio      'PSNR'           2
%%%             structural similarity index     'SSIM'           3
%%%             multiscale SSIM index           'MSSIM'          4
%%%             visual signal-to-noise ratio    'VSNR'           5
%%%             visual information fidelity     'VIF'            6
%%%             pixel-based VIF                 'VIFP'           7
%%%             universal quality index         'UQI'            8
%%%             image fidelity criterion        'IFC'            9
%%%             noise quality measure           'NQM'            10
%%%             weighted signal-to-noise ratio  'WSNR'           11
%%%             signal-to-noise ratio           'SNR'            12
%%%
%%%             This function performs various kind of error checking, such
%%%             that each supported algorithm should "work" with any input image.
%%%             Some of the algorithms, for instance, use a multi-scale 
%%%             space-frequency decomposition which requires the input signal
%%%             to be a certain size.  If any padding is required to make sure
%%%             a decomposition will function properly, it will be applied
%%%             automatically.  Also, most metrics are designed to operate on
%%%             a single color plane of data.  If a multi-plane image i
%%%             provided as input, this routine assumes that the data represents
%%%             an RGB image, and will extract the luminance component of the
%%%             image using the RGB->YCbCr transform utilized by the IJG JPEG
%%%             library.
%%%
%%%             The 'preprocess_metrix_mux' function is provided as a separate
%%%             routine in case a user intends to compute more than one
%%%             comparions using a specific input reference image.
%%%             
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Author:    Matthew Gaubatz
%%%  Version:   1.0
%%%  Date:      01/05/2007
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


function [metrix_value] = metrix_mux( reference_image, query_image, metrix_indicator )

[H_reference,W_reference,D_reference] = size( reference_image );
[H_query,W_query,D_query] = size( query_image );

%%%
%%% check that the input images are actual images
%%%
if (H_reference == 0) | (W_reference == 0)
    error('Error [metrix_mux]:  Reference image is zero-dimensional!');
end
if (H_query == 0) | (W_query == 0)
    error('Error [metrix_mux]:  Query image is zero-dimensional!');
end

%%%
%%% check that the input images are the same size
%%%
if ( (H_reference ~= H_query) | (W_reference ~= W_query) | (D_reference ~= D_query) )
    error('Error [metrix_mux]:  Reference and query images are not the same size!');
end


metrix_name_cell = get_name_cell_metrix_mux;

if isstr( metrix_indicator )
    %%%
    %%% convert input string to upper case
    %%%
    metrix_name = lower( metrix_indicator );
else
    %%%
    %%% map metric indicator to a function name
    %%%    
    if (metrix_indicator < 1) | (metrix_indicator > length( metrix_name_cell )) 
        %%%
        %%% alert the user that the metric indicator is not valid
        %%%
        error( sprintf('Error [metric_mux]:  Input metric indicator %i is not between 1 and %i\n        (and therefore does not correspond to a supported metric).', metrix_indicator, length(metrix_name_cell) ) );
        error('        (and therefore does not correspond to a supported metric).');
    end
    metrix_indicator = max(1, min(length(metrix_name_cell), metrix_indicator));    
    metrix_name = metrix_name_cell{ metrix_indicator };
end

%%%
%%% compute desired metric
%%%
for k = 1:length( metrix_name_cell )
    if strcmp( metrix_name, metrix_name_cell{k} ) ~= 0        
        %%%
        %%% preprocess the input images
        %%%
        reference_image = preprocess_metrix_mux( reference_image, metrix_name_cell{k} );
        query_image = preprocess_metrix_mux( query_image, metrix_name_cell{k} );
        %%%
        %%% call the desired metric
        %%%
        metrix_value = feval( sprintf('metrix_%s',metrix_name), reference_image, query_image );            
        return;
    end
end

%%%
%%% alert the user that the metrix indicator is not valid
%%%
error_str = sprintf('Error [metrix_mux]:  Input metrix indicator ''%s'' not recognized!\n\n', metrix_indicator);
error_str = [error_str sprintf('  A list of supported metrix indicator values is given below:\n\n')];;
for k = 1:length( metrix_name_cell )
    error_str = [error_str sprintf('  %i - ''%s''\n', k, metrix_name_cell{k})];
end
error( error_str );

