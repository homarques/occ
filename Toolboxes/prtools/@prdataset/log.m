%LOG Dataset overload

% $Id: log.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function c = log(a)

	d = log(a.data);
	c = setdata(a,d);

return
