%EIG Dataset overload
% See EIG for help.

% $Id: eig.m,v 1.3 2007/03/22 07:45:54 duin Exp $

function [c1,c2] = eig(a,b)
		
% When a single input is given, the eigenvalues of the (square) matrix
% a are returned. When two inputs are given, the generalized
% eigenvalues of the matrices are returned.
	
	a = datasetconv(a);

	if nargin == 1 && nargout == 1
		c1 = eig(a.data);
	elseif nargin == 2 && nargout == 1
		if isa(b,'prdataset'),
			b = datasetconv(b);
			c1 = eig(a.data,b.data);
		else
			c1 = eig(a.data,b);
		end
	elseif nargin == 1 && nargout == 2
		[c1,c2] = eig(a.data);
	elseif nargin ==2 && nargout == 2
		if isa(b,'prdataset'),
			b = datasetconv(b);
			c1 = eig(a.data,b.data);
		else
			c1 = eig(a.data,b);
		end
	else
		error('Illegal number of arguments')
	end 
return
