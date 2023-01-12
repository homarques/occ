%GETNAME Get dataset name
%
%   NAME = GETNAME(A,N)
%
% INPUT
%   A    Dataset
%   N    Number of characters in NAME (default: all)
%
% OUTPUT
%   NAME  Dataset name
%
% DESCRIPTION
% If N given, the return string has exactly N characters. This is done by
% truncation or by padding with blanks. This is useful for display purposes.

% $Id: getname.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function name = getname(a,n)

	name = a.name;
  % make sure name is a string
  if isempty(name), name = ''; end

	% If requested, truncate name or add spaces.

	if (nargin > 1) && ~isempty(n)
		if (length(name) > n)
			name = name(1:n);
		else
			name = [name,repmat(' ',1,n-length(name))];
		end
	end

return
