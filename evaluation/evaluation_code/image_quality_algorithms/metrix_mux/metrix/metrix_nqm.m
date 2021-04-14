%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%  FUNCTION:  metrix_nqm
%%%
%%%  INPUTS:    reference_image     - original image data 
%%%
%%%             query_image         - modified image data to be compared with
%%%                                   original image
%%%
%%%  OUTPUTS:   metrix_value        - NQM value
%%%
%%%  CHANGES:   NONE
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

function [metrix_value] = metrix_nqm(reference_image,query_image)


%%%
%%% veiwing angle is (in degrees) determined based on the assumption that
%%% the image is viewed at 3.5 picture heights away
%%%
viewing_angle = 1/3.5 * 180 / pi;

%%%
%%% estimate the dimesion of the image as the geometric mean
%%% of the horizonal and vertical dimensions
%%%
dim = sqrt( prod( size(reference_image) ));

metrix_value = nqm_modified(reference_image, query_image, viewing_angle, dim);
