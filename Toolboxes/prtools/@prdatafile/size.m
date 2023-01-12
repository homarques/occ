%SIZE Size of datafile. Datafile overload
%
%	[M,K] = SIZE(A)
%
% M: number of objects
% K: number of features

% $Id: size.m,v 1.4 2008/08/06 08:39:42 duin Exp $

function [varargout] = size(a,dim)
				
	[m,k] = size(a.prdataset);
	
% 	if ((nargin == 1) || ((nargin > 1) && (dim == 2))) && k == 0
% 		%we need to find k and it has not been set.
% 		%so, get first object
% 		b = readdatafile(a,1,0);
% 		k = size(b,2);
% 	end
	
	s = [m,k];
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

