%TIMES Dataset overload

% $Id: times.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function c = times(a,b)

	sa = size(a);
	sb = size(b);

	% Check whether the sizes are the same.
 
	if (any(sa ~= 1) && any(sb ~= 1) && any(sa ~= sb))
		error('datasets should have equal size')
	end

	if (isa(a,'prdataset')) && (~isa(b,'prdataset'))
		c = a;
		data = a.data .* b;
	elseif ~isa(a,'prdataset') && isa(b,'prdataset')
		c = b;
		data = a .* b.data;
	else
		c = a;
		data = a.data .* b.data;
	end
	c = setdata(c,data);

return
