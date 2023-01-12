%CHECK12 Decide between monadic and dyadic datafile operations
%
% [CHECK,A,B] = CHECK12(A,B)

function [check,a,b] = check12(a,b);

if isdatafile(a)
  
  if isdatafile(b)
	  if size(b,2) ~= size(a,2) || getfeatsize(b) ~= getfeatsize(a)
		  error('Datafiles should have equal image sizes')
    end
    if size(a,1) ~= 1 && size(b,1) ~= 1 && size(a,1) ~= size(b,1)
      error('Datafiles should have the same size')
    end
    if size(a,1) ~= size(b,1)
      if size(a,1) == 1
        a = +a;
      end
      if size(b,1) == 1
        b = +b;
      end
      [check,a,b] = feval(mfilename,a,b);
    else
      check = 'both';
    end
	else
    check = 'first';
		if isdataset(b)
			b = data2im(b);
		else
    	b = double(b);
		end
    fsize = getfeatsize(a);
    if length(fsize) == 3 && fsize(3) == 1
      fsize(3) = [];
    end
    if (length(size(b)) == 2) && (all(size(b) == [1,1]))
			if size(a,1) == 1
      	b = b*ones(fsize);
			end
    elseif (length(size(b)) == length(fsize)) && (all(size(b) == fsize))
      ;
    else
      generror;
    end
  end
  
else
  
	if isdataset(a)
		a = data2im(a);
	else
  	a = double(a);
	end
  if isdatafile(b)
    check = 'last';
    fsize = getfeatsize(b);
    if length(fsize) == 3 && fsize(3) == 1
      fsize(3) = [];
    end
    if (length(size(a)) == 2) && (all(size(a) == [1,1]))
			if size(b,1) == 1
      	a = a*ones(fsize);
			end
    elseif (length(size(a)) == length(fsize)) && (all(size(a) == fsize))
      ;
    else
      generror;
    end
  else
    generror;
  end
  
end

return

function generror
  error('Datafiles can only be combined with scalars, or with datafiles or images of the right size')
return
  
  