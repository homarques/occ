%XOR Dataset overload

% $Id: xor.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function c = xor(a,b)
			if isa(a,'prdataset') & ~isa(b,'prdataset')
		c = a;
		d = xor(a.data,b);
	elseif ~isa(a,'prdataset') & isa(b,'prdataset')
		c = b;
		d = xor(a,b.data);
	else
		c = a;
		d = xor(a.data,b.data);
	end
	c = setdata(c,d);
return
