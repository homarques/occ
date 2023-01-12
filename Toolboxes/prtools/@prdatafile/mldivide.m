%MLDIVIDE Datafile overload

function c = mldivide(aa,bb)
	  
	[check,a,b] = check12(aa,bb);
	
	switch check
		case 'both'
			c = dyadic(a,'mldivide',b);
		case 'first'
			if is_scalar(bb)
				c = a*filtm([],'ldivide',b);
			else
				c = a*filtm([],'mldivide',b);
			end
    case 'last'
			if is_scalar(aa)
				c = b*filtm([],'rdivide',a);
			else
				c = b*filtm([],'mrdivide',a);
			end
  end
		
return;
 