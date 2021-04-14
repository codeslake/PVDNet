%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%  FUNCTION:  get_name_cell_metrix_mux
%%%
%%%  INPUTS:    NONE
%%%  
%%%  OUTPUTS:   A cell containg the names of all metrix indicator strings
%%%             associated with metrics supported by the MeTriX MuX
%%%             package.
%%%
%%%  CHANGES:   NONE
%%%
%%%  NOTES:     If support for an additional algorithm is added, an appropriate
%%%             indicator string should be added using this routine.
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Author:    Matthew Gaubatz
%%%  Version:   1.1
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

function metrix_name_cell = get_name_cell_metrix_mux

metrix_name_cell{1} = 'mse';
metrix_name_cell{2} = 'psnr';
metrix_name_cell{3} = 'ssim';
metrix_name_cell{4} = 'mssim';
metrix_name_cell{5} = 'vsnr';
metrix_name_cell{6} = 'vif';
metrix_name_cell{7} = 'vifp';
metrix_name_cell{8} = 'uqi';
metrix_name_cell{9} = 'ifc';
metrix_name_cell{10} = 'nqm';
metrix_name_cell{11} = 'wsnr';
metrix_name_cell{12} = 'snr';
