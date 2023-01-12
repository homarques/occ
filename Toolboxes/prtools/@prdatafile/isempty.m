%ISEMPTY Datafile overload
%
%	I = ISEMPTY(A,FIELD)
%
% INPUT
%  A     Datafile
%  FIELD Datafile field
%
% OUTPUT
%  I     Flag, 1 if field is empty, 0 otherwise. 
%
% DESCRIPTION
% Dataset overload for ISEMPTY. This is particulary useful for
% ISEMPTY(A) to test on an empty datafile, and
% ISEMPTY(A,'prior') to test on an undefined PRIOR field.
%
% A datafile is empty if no files are found in the directory DIR
% after a PRDATAFILE(DIR) definition.
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% DATAFILE

% $Id: isempty.m,v 1.3 2007/04/16 08:35:13 duin Exp $

function i = isempty(a,field)
		
	if nargin < 2
		s = size(a.prdataset,1);
		i = (s==0);
	elseif isfield(a,field)
		i = isempty(a.(field));
	else
		i = isempty(a.prdataset.(field));
	end

return
