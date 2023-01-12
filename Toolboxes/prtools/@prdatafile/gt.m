%GT Datafile overload

function c = gt(a,b)
	  
	[check,a,b] = check12(a,b);
	
	switch check
		case 'both'
			c = dyadic(a,'gt',b);
		case 'first'
			c = a*filtm([],'gt',b);
    case 'last'
      c = b*filtm([],'le',a);
  end

return;
 