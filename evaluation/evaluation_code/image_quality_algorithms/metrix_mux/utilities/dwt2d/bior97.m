%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%  FUNCTION:  bior97
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
%%%  NOTES:     Computes analysis and synthesis filters for a 9/7 biorthogonal
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

lo_d(1) =  0.85269867900889;
lo_d(2) =  0.37740285561283;
lo_d(3) = -0.11062440441844;
lo_d(4) = -0.02384946501956;
lo_d(5) =  0.03782845550726;

hi_d(1) = -0.78848561640558;
hi_d(2) =  0.41809227322162;
hi_d(3) =  0.04068941760916;
hi_d(4) = -0.06453888262870;
hi_d(5) = 0;

hi_r = [lo_d(1) -lo_d(2) lo_d(3) -lo_d(4) lo_d(5)];
lo_r = [hi_d(1) -hi_d(2) hi_d(3) -hi_d(4) hi_d(5)];

lo_d = [fliplr(lo_d(2:end)) lo_d];
hi_d = [fliplr(hi_d(2:end)) hi_d];
lo_r = [fliplr(lo_r(2:end)) lo_r];
hi_r = [fliplr(hi_r(2:end)) hi_r];
