%MEDIAN Dataset overload

% $Id: median.m,v 1.3 2007/03/22 07:45:54 duin Exp $

function s = median(a,dim)
	
	if (nargin == 1)
		s = median(a.data);
	else
		if (dim == 1)
			s = median(a.data,1);
		elseif (dim == 2)
			s = median(a.data,2);
			%s = setdata(a,s,'median'); % just a single feature with median values
		else
			error('Dimensionality should be either 1 or 2.')
		end
	end
return;

