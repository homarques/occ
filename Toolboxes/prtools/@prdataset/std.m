%STD Dataset overload
%
%   [S,U] = STD(A,FLAG,DIM)
%
% Computes std. dev. S and mean U in a single run for consistency with datafile overload.

function [s,u] = std(a,n,dim)
	
	
		if nargin < 3, dim = 1; end
		if nargin < 2, n = 0; end
	
		s = std(a.data,n,dim);
    u = mean(a.data,dim);
	
	return
