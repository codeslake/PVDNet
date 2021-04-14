%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%  FUNCTION:  bior53
%%%
%%%  INPUTS:    NONE
%%%
%%%  OUTPUTS:   lo_d                - low-pass decomposotion filter
%%%
%%%             hi_d                - high-pass decomposition filter
%%%
%%%             lo_r                - low-pass reconstruction filter
%%%
%%%             hi_r                - high-pass reconstruction filter
%%%
%%%  CHANGES:   NONE
%%%
%%%  NOTES:     Computes analysis and synthesis filters for a 5/3 biorthogonal
%%%             wavelet transfiorm.
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

function [lo_d,hi_d,lo_r,hi_r] = bior97

lo_d = [-1 2 6 2 -1]/8;
hi_d = [0 -1 2 -1 0]/2;
lo_r = [0 1 2 1 0]/2;
hi_r = [-1 -2 6 -2 -1]/8;


