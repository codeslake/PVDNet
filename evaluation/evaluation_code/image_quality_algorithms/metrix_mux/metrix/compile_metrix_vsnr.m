%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%  FUNCTION:  compile_metrix_vsnr
%%%
%%%  INPUTS:    NONE
%%%  
%%%  OUTPUTS:   NONE
%%%
%%%  CHANGES:   Builds a MEX interface to a DWT routine called by the VSNR
%%%             metric code; if the build does not succeed, the package defaults
%%%             to using a Matlab-only approach.  Currently, the MEX interface
%%%             is only supported for newer Windows-based platforms.
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

function compile_metric_vsnr

fprintf('    Building VSNR MEX interface for DWT...');

if ispc == 1
    fprintf('(Windows)...');    
    try
        compile_imdwt_modified('imdwt_modified.dll');            
    catch
        fprintf('    [Failed!]\n');
        fprintf('    Defaulting to Matlab-based DWT...');        
    end
else
    fprintf('(Linux/Mac)...');    
        fprintf('    [Not Supported!]\n');
        fprintf('    Defaulting to Matlab-based DWT...');        
end

fprintf('[Success!]\n');

