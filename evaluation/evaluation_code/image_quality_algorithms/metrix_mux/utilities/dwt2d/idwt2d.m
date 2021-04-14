%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%  FUNCTION:  idwt2d
%%%
%%%  INPUTS:    data                - 2-D wavelet transform data
%%%
%%%             nlev                - desired number of transform levels
%%%
%%%             mode                - filter type ('97' or '53')
%%%
%%%  OUTPUTS:   data                - untransformed image data
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

function data = idwt2d(data,nlev,mode)


try 
    mode = mode;
catch
    mode = '97';
end

if mode == '97'    
    [lod,hid,lor,hir] = bior97;
    
else
    [lod,hid,lor,hir] = bior53;    
end



%data = idwt2d_helper(data,lor,hir,nlev);

[H,W] = size(data);

for iter_ctr = (nlev):-1:1
    
    
    data_temp = data(1:H/(2^(iter_ctr-1)),1:W/(2^(iter_ctr-1)));
    
    
    data(1:H/(2^(iter_ctr-1)),1:W/(2^(iter_ctr-1))) = idwt2d_helper(data_temp,lor,hir);
    
end



function data = idwt2d_helper(data,lo_filt,hi_filt)


data = conv_row_wfilters_up(data,lo_filt,hi_filt);
data = conv_row_wfilters_up(data.',lo_filt,hi_filt).';

function [data] = conv_row_wfilters_up(data,lo_filt,hi_filt)


[H,W] = size(data);

N = length(lo_filt)-1;
L = N/2;

% apply horizontal filters
for h = 1:H

    row = data(h,:);

    row_lo = zeros(1,W);
    row_lo(1:2:end) = row(1:W/2);

    row_hi = zeros(1,W);
    row_hi(2:2:end) = row(W/2+1:end);
    
       
    
    row_lo = [fliplr(row_lo(2:(L+1))) row_lo fliplr(row_lo((end-L):end-1))];
    row_hi = [fliplr(row_hi(2:(L+1))) row_hi fliplr(row_hi((end-L):end-1))];
        
    
    row_lo = conv(row_lo,lo_filt);
    row_lo = row_lo(N+1:end-N);
    
    
    row_hi = conv(row_hi,hi_filt);
    row_hi = row_hi(N+1:end-N);
    
    row = row_lo + row_hi;
    
    
    data(h,:) = row;
    
    
end
