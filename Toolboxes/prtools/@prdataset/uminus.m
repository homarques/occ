%UMINUS Dataset overload

% $Id: uminus.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function c = uminus(a)

	c = setdata(a,-(a.data));

return
