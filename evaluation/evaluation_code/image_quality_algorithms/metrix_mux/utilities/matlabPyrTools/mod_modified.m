%%%MM%%%
%%%MM%%% This file ('mod.m') has been renamed to 'mod_modified.m' to prevent
%%%MM%%% complaints from newer versions of Matlab.
%%%MM%%%

% M = mod(A,B)
% 
% Modulus operator: returns A mod B.
% Works on matrics, vectors or scalars.
% 
% NOTE: This function is a Matlab-5 builtin, but was missing from Matlab-4.

% Eero Simoncelli, 7/96.

function m = mod(a,n)

m = a - n .* floor(a./n);
return;

