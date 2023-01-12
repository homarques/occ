%STD Datafile overload
%
%   [S,U] = STD(A,FLAG,DIM)
%
% A - Datafile
% FLAG - FLAG==0 for the default normalization by N-1, or
%        FLAG==1 for normalizing by N.
%
% S - Vector of feature standard deviatons
% U - Mean vector
%
% Computes std. dev. S and mean U in a single run for speed.
% Objects are assumed to have the same number of features.
% Take care that the feature size of A has been correctly set.
% The routine is useful in case the data is too large to be
% converted to a dataset first.

function [s,u] = std(a,flag,dim)
	
	
	if nargin < 3, dim = 1; end
	if nargin < 2, flag = 0; end
	
	if flag ~= 0 && flag ~= 1
		error('Flag should be 0 or 1')
	end
	
	if dim == 1
		u = zeros(1,size(a,2));
		v = zeros(1,size(a,2));
		next = 1;
		while next > 0
			[b,next] = readdatafile(a,next);
			u = u + sum(b,1);
			v = v + sum((+b).^2,1);
		end
		n = size(a,1);
		s2 = v - (u.^2)/n; 
		if flag
			s = sqrt(s2/n);
		else
			s = sqrt(s2/(n-1));
		end
    u = u/n;
	elseif dim == 2
		s = zeros(size(a,1),1);
		u = zeros(size(a,1),1);
		next = 1;
		while next > 0
			[b,next,J] = readdatafile(a,next);
			s(J) = std(b,flag,2);
      u(J) = mean(b,2);
		end
	else
		error('Illegal dimension requested')
	end

	return
