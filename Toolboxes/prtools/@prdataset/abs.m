%ABS Dataset overload

% $Id: abs.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function c = abs(a)

		
d = abs(a.data);
c = setdata(a,d);

return
