%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%  FUNCTION:  metrix_mse
%%%
%%%  INPUTS:    reference_image     - original image data 
%%%
%%%             query_image         - modified image data to be compared with
%%%                                   original image
%%%
%%%  OUTPUTS:   metrix_value        - MSE value
%%%
%%%  CHANGES:   NONE
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

function [metrix_value] = metrix_mse(reference_image,query_image)

metrix_value = mean( (reference_image(:) - query_image(:)).^2 );
