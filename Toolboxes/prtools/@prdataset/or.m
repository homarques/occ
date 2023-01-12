%OR Dataset overload

% $Id: or.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function c = or(a,b)
			if isa(a,'prdataset') & ~isa(b,'prdataset')
		c = a;
		d = a.data || b;
	elseif ~isa(a,'prdataset') & isa(b,'prdataset')
		c = b;
		d = a | b.data;
	else
		c = a;
		d = a.data | b.data;
	end
	c = setdata(c,d);
return
