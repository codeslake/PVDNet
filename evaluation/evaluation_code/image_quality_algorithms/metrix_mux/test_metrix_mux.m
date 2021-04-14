%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%  FUNCTION:  test_metrix_mux
%%%
%%%  INPUTS:    NONE
%%%
%%%  OUTPUTS:   NONE
%%%
%%%  CHANGES:   Loads a pair of images (included with the VSNR algorithm code),
%%%             then runs every algorithm included with the MeTriX MuX
%%%             package on these images, to make sure that they no
%%%             execptions are thrown.
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

function test_metrix_mux

%%%
%%% initialize error counter;
%%%
total_error_counter = 0;

%%%
%%% load test images
%%%
try
    reference_image = double(imread('horse.bmp'));
    query_image = double(imread('horse.JP2.bmp'));
catch
    fprintf('Error [test_metrix_mux]:  Cannot load test image files!\n');
    total_error_counter = total_error_counter + 1;
end

%%%
%%% run all the algorithms
%%%
metrix_name_cell = get_name_cell_metrix_mux;
for k = 1:length( metrix_name_cell )
    try
        metrix_mux( reference_image, query_image, metrix_name_cell{k} );
        fprintf('Algorithm %s computed successfully!\n', metrix_name_cell{k} );
    catch
        fprintf('Error [test_metrix_mux]:  algorithm %s did not compute correctly!\n', metrix_name_cell{k} );
        total_error_counter = total_error_counter + 1;
    end
end

fprintf('Total error count:  %i\n',total_error_counter);
