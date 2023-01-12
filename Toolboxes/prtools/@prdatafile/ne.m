%NE Datafile overload

function c = ne(a,b)
	  
	[check,a,b] = check12(a,b);
	
	switch check
		case 'both'
			c = dyadic(a,'ne',b);
		case 'first'
			c = a*filtm([],'ne',b);
    case 'last'
      c = b*filtm([],'ne',a);
  end
		
return;
 