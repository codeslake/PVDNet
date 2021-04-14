%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%  FUNCTION:  configure_metrix_mux
%%%
%%%  INPUTS:    NONE
%%%  
%%%  OUTPUTS:   NONE
%%%
%%%  CHANGES:   Sets the Matlab path variable to include folders that execute 
%%%             quality metric computation routines contained in the MeTriX MuX
%%%             package, and compiles any non-Matlab code used for faster 
%%%             computation.  Specifically, the routine searches for any .m file
%%%             in the 'metrix' folder starting with the prefix 
%%%             'compile_metrix_' and executes it.
%%%
%%%  NOTES:     This routine is the universal setup command for the MeTriX MuX
%%%             package.  All configuration operations for the package are
%%%             accomplished by calling
%%%
%%%             >> configure_metrix_mux
%%%             
%%%             from the Matlab prompt.
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

function configure_metrix_mux

%%%
%%% add MeTriX MuX routines to the Matlab path
%%%
fprintf('Setting MeTriX MuX path...');
configure_metrix_mux_name = 'configure_metrix_mux.m';
configure_metrix_mux_path = which( configure_metrix_mux_name );
metrix_mux_path = configure_metrix_mux_path( 1:end-length( configure_metrix_mux_name ) );
path( genpath(metrix_mux_path), path );
savepath;
fprintf('[Done!]\n');

%%%
%%% create list of compilation routines
%%%
fprintf('Compiling list of compilations routines...');
compile_file_list = dir('metrix/compile_metrix_*.m');
fprintf('%i found...', length(compile_file_list));
fprintf('[Done!]\n');

%%%
%%% execute compilation routines
%%%
fprintf('Executing compilation routines...\n');
for k = 1:length(compile_file_list)

    %%%
    %%% removing the '.m' from each compilation file
    %%% name to retrieve the routine to be invoked
    %%%
    compile_command_k = compile_file_list(k).name(1:end-2);
    fprintf('%i - %s\n', k, compile_command_k );
    feval( compile_command_k );
    
end
fprintf('[Done!]\n');

test_metrix_mux;
