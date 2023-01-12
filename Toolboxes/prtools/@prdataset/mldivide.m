%MLDIVIDE Dataset overload

% $Id: mldivide.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function c = mldivide(a,b)

	if (isa(a,'prdataset')) && (~isa(b,'prdataset'))
		c = a.data \ b;
	elseif (~isa(a,'prdataset') && isa(b,'prdataset'))
		c = a \ b.data;
	else
		c = a.data \ b.data;
	end

return
