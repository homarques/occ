%MPOWER Datafile overload

function c = mpower(a,b)
	
	  
	if is_scalar(b)
		c = a*filtm([],'power',b);
	elseif is_scalar(a)
    c = exp(b.*log(a)); % solve by a.^b = exp(b.*log(a))
	else
		nodatafile;
	end

return