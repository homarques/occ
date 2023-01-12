%MRDIVIDE Datafile overload

function c = mrdivide(aa,bb)
	  
	[check,a,b] = check12(aa,bb);
	
	switch check
		case 'both'
			c = dyadic(a,'mrdivide',b);
		case 'first'
			if is_scalar(bb)
				c = a*filtm([],'rdivide',b);
			else
				c = a*filtm([],'mrdivide',b);
			end
    case 'last'
			if is_scalar(aa)
				c = b*filtm([],'ldivide',a);
			else
				c = b*filtm([],'mldivide',a);
			end
  end
		
return;
 