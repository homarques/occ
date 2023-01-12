%NOT Logical NOT. Dataset overload

% $Id: not.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function c = not(a)
		d = ~a.data;
c = setdata(a,d);
return
