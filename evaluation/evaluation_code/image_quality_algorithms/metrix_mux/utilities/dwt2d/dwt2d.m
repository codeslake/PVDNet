%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%  FUNCTION:  dwt2d
%%%
%%%  INPUTS:    data                - input image data
%%%
%%%             nlev                - desired number of transform levels
%%%
%%%             mode                - filter type ('97' or '53')
%%%
%%%  OUTPUTS:   data                - a 2-D wavelet transform of the input
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

function data = dwt2d(data,nlev,mode)

%%%
%%% pick the decomposition mode
%%%
try 
    mode = mode;
catch
    mode = '97';
end

%%%
%%% grab filters
%%%
if mode == '97'    
    [lod,hid,lor,hir] = bior97;
    
else
    [lod,hid,lor,hir] = bior53;    
end


%%%
%%% compute the DWT
%%%
data = dwt2d_helper(data,lod,hid,nlev);
    
%%%
%%% recursive DWT helper function
%%%
function data = dwt2d_helper(data,lo_filt,hi_filt,iter)

if iter > 0
    
    [H,W] = size(data);
    
    data = conv_row_wfilters_down(data,lo_filt,hi_filt);
    data = conv_row_wfilters_down(data.',lo_filt,hi_filt).';
    
    data(1:H/2,1:W/2) = dwt2d_helper(data(1:H/2,1:W/2),lo_filt,hi_filt,iter-1);
    
end

%%%
%%% 1-dimensionsal convolution/downsampling routine
%%%
function [data] = conv_row_wfilters_down(data,lo_filt,hi_filt)

[H,W] = size(data);

N = length(lo_filt)-1;
L = N/2;

%%%
%%% apply horizontal filters
%%%

for h = 1:H
    
    row = data(h,:);
    row = [fliplr(row(2:(L+1))) row fliplr(row((end-L):end-1))];
    
    row_lo = conv(row,lo_filt);
    row_lo = row_lo(N+1:end-N);
    
    
    row_hi = conv(row,hi_filt);
    row_hi = row_hi(N+1:end-N);
    
    row = [row_lo(1:2:end) row_hi(2:2:end)];
    
    data(h,:) = row;
    
end
