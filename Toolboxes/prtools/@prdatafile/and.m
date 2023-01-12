%AND Datafile overload

function c = and(a,b)
	  
	[check,a,b] = check12(a,b);
	
	switch check
		case 'both'
			c = dyadic(a,'and',b);
		case 'first'
			c = a*filtm([],'and',b);
    case 'last'
      c = b*filtm([],'and',a);
  end
		
return;
 