%PLUS Datafile overload

function c = plus(a,b)
	  
  [check,a,b] = check12(a,b);
	
	switch check
		case 'both'
			c = dyadic(a,1,b,1);
		case 'first'
			c = a*filtm([],'plus',b);
    case 'last'
      c = b*filtm([],'plus',a);
  end
		
return;
 