%POWER Datafile overload

function c = power(a,b)
	
	  
	[check,a,b] = check12(a,b);
  
	switch check
		case 'both'
			c = dyadic(a,'power',b);
		case 'first'
			c = a*filtm([],'power',b);
    case 'last'
      c = exp(b.*log(a)); % solve by a.^b = exp(b.*log(a))
  end
		
return
