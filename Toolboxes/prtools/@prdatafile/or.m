%OR Datafile overload

function c = or(a,b)
	  
	[check,a,b] = check12(a,b);
	
	switch check
		case 'both'
			c = dyadic(a,'or',b);
		case 'first'
			c = a*filtm([],'or',b);
    case 'last'
      c = b*filtm([],'or',a);
  end
		
return;
 