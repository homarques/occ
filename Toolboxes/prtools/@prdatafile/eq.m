%EQ Datafile overload

function c = eq(a,b)
	  
	[check,a,b] = check12(a,b);
	
	switch check
		case 'both'
			c = dyadic(a,'eq',b);
		case 'first'
			c = a*filtm([],'eq',b);
    case 'last'
      c = b*filtm([],'eq',a);
  end
		
return;
 