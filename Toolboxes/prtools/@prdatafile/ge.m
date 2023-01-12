%GE Datafile overload

function c = ge(a,b)
	  
	[check,a,b] = check12(a,b);
	
	switch check
		case 'both'
			c = dyadic(a,'ge',b);
		case 'first'
			c = a*filtm([],'ge',b);
    case 'last'
      c = b*filtm([],'lt',a);
  end
		
return;
 