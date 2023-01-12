%SETNAME Set the name of a dataset
%
%   A = SETNAME(A,NAME)
%
% The NAME of a dataset A is a string that may be used for identifying 
% the dataset and for annotating plots and other outputs.

% $Id: setname.m,v 1.3 2007/01/31 13:48:19 davidt Exp $

function a = setname(a,name,varargin)
		if (~ischar(name) && ~isempty(name))
		error('The name should be a string')
	end
	if nargin>2
		a.name = sprintf(name,varargin{:});
	else
		a.name = name;
	end
return;

