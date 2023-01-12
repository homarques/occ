%UPLUS Datafile overload

function c = uplus(a)

		
	if nargout > 0 && size(a,1) > 1
		error('Command not implemented for datafile. Convert to dataset first')
	else
		a = prdataset(a);
		c = getdata(a);
	end

return
