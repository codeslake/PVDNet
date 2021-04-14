%%%MM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%MM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%MM%%% compile_imdwt, Modified Version
%%%MM%%%
%%%MM%%% The author of this modified version is with the Visual 
%%%MM%%% Communications Laboratory, in department of Electrical and 
%%%MM%%% Computer Engineering at Cornell University.  The original 
%%%MM%%% code was written by Damon Chandler at Cornell University.
%%%MM%%% 
%%%MM%%% This build routine compiles a MEX interface for an image wavelet
%%%MM%%% transform routine.
%%%MM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%MM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%MM%%% Author:    Matthew Gaubatz
%%%MM%%% Version:   1.0
%%%MM%%% Date:      01/05/2007
%%%MM%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%MM%%% Copyright (c) 2007 Visual Communications Lab, Cornell University 
%%%MM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%MM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%MM%%%
%%%MM%%% [BEGIN CHANGE]
%%%MM%%%
%%%MM%%% replace the original build script with a function that
%%%MM%%% parameterizes the name of the target build module
%%%MM%%%
function compile_imdwt_modified(target_build_module)

%%%MM%%%
%%%MM%%% locate the MEX source file (assuming that this very file is
%%%MM%%% stored in the same folder)
%%%MM%%%
this_file_name = 'compile_imdwt_modified.m';
this_file = which( this_file_name );

target_source_file = sprintf('%simdwt.cpp', this_file(1 : findstr( this_file, this_file_name ) - 1 ));
out_directory_name = this_file(1:end-length(this_file_name)-length('imdwt_cpp')-1);

compile_command = sprintf('mex ''%s'' -outdir ''%s'' -output ''%s''', target_source_file, out_directory_name, target_build_module);
eval( compile_command );

%%%MM%%%
%%%MM%%% comment out previous non-parameterized version
%%%MM%%%
%%%MM%%%mex 'imdwt.cpp' -outdir '../' -output 'imdwt_modified.dll'
%%%MM%%%
%%%MM%%% [END CHANGE]
%%%MM%%%
