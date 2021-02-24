%ISEMPTY Dataset overload
%
%	I = ISEMPTY(A,FIELD)
%
% INPUT
%  A     Dataset
%  FIELD Dataset field, default 'objsize'
%
% OUTPUT
%  I     Flag, 1 if field is empty, 0 otherwise. 
%
% DESCRIPTION
% Dataset overload for ISEMPTY. This is particulary useful for
% ISEMPTY(A) to test on an empty dataset, and
% ISEMPTY(A,'prior') to test on an undefined PRIOR field.
%
% Note that ISEMPTY(A) is not consistent with ISEMPTY(DOUBLE(A)) as a
% DOUBLE array of size [0,k] is considered to be empty according to Matlab,
% but A = PRDATASET(ones(0,k)) is not empty as it contains feature size
% information. An empty dataset can only be constructed by A = PRDATASET,
% or by A = PRDATASET([]).
%
% SEE ALSO (<a href="http://37steps.com/prtools">PRTools Guide</a>)
% PRDATASET, SETPRIOR, GETPRIOR
