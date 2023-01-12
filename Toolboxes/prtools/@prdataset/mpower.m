%MPOWER Dataset overload

% $Id: mpower.m,v 1.3 2007/03/22 07:45:54 duin Exp $

function c = mpower(a,b)

		
	if (isa(a,'prdataset')) && (~isa(b,'prdataset'))
		c = a;
		data = a.data ^ b;
	elseif (~isa(a,'prdataset')) && (isa(b,'prdataset'))
		c = b;
		data = a ^ b.data;
	else
		c = a;
		data = a.data ^ b.data;
	end
	c = setdata(c,data);

return
