%LT Datafile overload

function c = lt(a,b)
	  
	[check,a,b] = check12(a,b);
	
	switch check
		case 'both'
			c = dyadic(a,'lt',b);
		case 'first'
			c = a*filtm([],'lt',b);
    case 'last'
      c = b*filtm([],'ge',a);
  end
		
return;
 