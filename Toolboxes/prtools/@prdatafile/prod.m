%PROD Datafile overload

function s = prod(a,dim)
	
	
	if nargin == 1, dim = 1; end
	
	if dim == 1
		s = ones(1,size(a,2));
		next = 1;
		while next > 0
			[b,next] = readdatafile(a,next);
			s = s .* prod(b,1);
		end
		s = reshape(s,getfeatsize(a));
	elseif dim == 2
		s = ones(size(a,1),1);
		next = 1;
		while next > 0
			[b,next,J] = readdatafile(a,next);
			s(J) = s(J) .* prod(b,2);
		end
	else
		error('Illegal dimension requested')
	end

	return
