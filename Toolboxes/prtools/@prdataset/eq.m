%EQ Dataset overload

function c = eq(a,b)
		if (isa(a,'prdataset')) && (~isa(b,'prdataset'))
		c = a;
		d = (a.data == b);
	elseif (~isa(a,'prdataset')) && (isa(b,'prdataset'))
		c = b;
		d = (a == b.data);
	else
		c = a;
		d = (a.data == b.data);
	end
	c = setdata(c,d);
return;
