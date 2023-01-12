%VAR Datafile overload
%
%   [V,U] = VAR(A,W)
%
% A - Datafile
% W - Vector of weights, one per object
%
% V - Vector of feature variances
% U - Mean vector
%
% Computes variance V and mean U in a single run for speed.
% Objects are assumed to have the same number of features.
% Take care that the feature size of A has been correctly set.
% The routine is useful in case the data is too large to be
% converted to a dataset first.

function [s,u] = var(a,w)
	
	
	if nargin < 2
		[s,u] = std(a,0,1);
    s = s.^2;
	else
		[m,k] = size(a);
		if length(w) == 1 && w == 1
			w = ones(m,1);
		end
		if any(size(w) ~= [m,1])
			error('Weight vector has wrong size')
		end
		if any(w<0)
			error('Weights should be positive')
		end
		w = w/sum(w);
		u = zeros(1,size(a,2));
		v = zeros(1,size(a,2));
		next = 1;
		while next > 0
			[b,next,J] = readdatafile(a,next);
			b = +b;
			u = u + w(J)*b;
			v = v + w(J)*(b.^2);
		end
		s = (v - (u.^2)); 
	end

return
