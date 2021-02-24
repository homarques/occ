%ISDOUBLE Test on doubles

function n = isdouble(m)

		
	if isa(m,'double')
		n = 1;
	else
		n = 0;
	end

	return
