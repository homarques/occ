%LDIVIDE Datafile overload

function c = ldivide(aa,bb)
	  
	[check,a,b] = check12(aa,bb);
	
	switch check
		case 'both'
			c = dyadic(a,'ldivide',b);
		case 'first'
			c = a*filtm([],'ldivide',b);
    case 'last'
			c = b*filtm([],'rdivide',a);
  end
		
return;
 