%SETNAME Set name field in mapping
%
%    W = SETNAME(W,NAME)

% $Id: setname.m,v 1.3 2007/01/31 13:48:19 davidt Exp $

function w = setname(w,name,varargin)

		
	if ~isempty(name) && ~ischar(name)
		error('Mapping description or name should be given as string')
	end
	if nargin>2
		w.name = sprintf(name,varargin{:});
	else
		w.name = name;
	end

	return
