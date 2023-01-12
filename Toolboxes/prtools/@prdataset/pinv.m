%PINV Dataset overload

% $Id: pinv.m,v 1.3 2007/03/22 07:45:54 duin Exp $

function c = pinv(a)
			nodatafile(a);
	c = pinv(a.data);
	%DXD the result is not casted to dataset: feature or bug?
	%RD  feature!
return
