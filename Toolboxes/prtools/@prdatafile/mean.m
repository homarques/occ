%MEAN Datafile overload

function s = mean(a,dim)
	
	
	if nargin == 1, dim = 1; end
	
	if dim == 1
		s = zeros(1,size(a,2));
		next = 1;
		while next > 0
			[b,next] = readdatafile(a,next);
      if size(b,2) ~= numel(s)
        error('Objects should have the same size')
      end
			s = s + sum(b,1);
		end
		s = s/size(a,1);
	elseif dim == 2
		next = 1;
		s = zeros(size(a,1),1);
		while next > 0
			[b,next,J] = readdatafile(a,next);
			s(J) = mean(b,2);
		end
	else
		error('Illegal dimension requested')
	end

	return
