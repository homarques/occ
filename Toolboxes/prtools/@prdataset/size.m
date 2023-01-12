%SIZE Size of dataset. Dataset overload
%
%	[M,K] = SIZE(A)
%
% M: number of objects
% K: number of features

% $Id: size.m,v 1.3 2006/12/19 12:12:13 duin Exp $

function [varargout] = size(a,dim)
		
	if isempty(a.data)  % needed for datafiles
		if isempty(a.objsize)
			s(1) = 0;
		else
			s(1) = prod(a.objsize);
		end
		if isempty(a.featsize)
			s(2) = 0;
		else
			s(2) = prod(a.featsize);
		end
	else
		s = size(a.data);
	end

	if nargin == 2
		s = s(dim);
	end
	if nargout == 0
		s+0     %just to get "ans =" 
	elseif nargout == 1
		varargout{1} = s;
	else
		v = ones(1:2);
		v(1:2) = s;
		for i=1:nargout
			varargout{i} = v(i);
		end 
	end
	
return

