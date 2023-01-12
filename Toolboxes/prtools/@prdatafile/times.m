%TIMES Datafile overload

function c = times(a,b)
	  
	[check,a,b] = check12(a,b);
	
	switch check
		case 'both'
			c = dyadic(a,'times',b);
		case 'first'
			c = a*filtm([],'times',b);
    case 'last'
      c = b*filtm([],'times',a);
  end
		
return;
 