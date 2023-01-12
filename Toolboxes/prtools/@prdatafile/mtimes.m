%MTIMES Datafile overload

function c = mtimes(a,b)
	  
	if is_scalar(b)
		c = a*filtm([],'times',b);
	elseif isa(b,'double')
		if ~is_scalar(a)
			error('Scalar variable or mapping expected')
		end
		a = setfeatsize(a,size(a,2));
		c = a*filtm([],'mtimes',b);
	elseif is_scalar(a)
		c = b*filtm([],'times',a);
  elseif isa(b,'prmapping')
    % due to a bug in Octave we are here instead of in @prmapping/mtimes
    % so we do here what should have been done there
    if (nargout >= 1)
      c = prmap(a,b);
    else
      prmap(a,b)
    end
  else
		nodatafile;
	end

		
return;
 