%FLOOR Dataset overload

function c = floor(a)

	d = floor(a.data);
	c = setdata(a,d);

return
