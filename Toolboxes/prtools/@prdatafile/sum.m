%SUM Datafile overload

function s = sum(a,dim)
	
	
	if nargin == 1, dim = 1; end % will go wrong, but is consistent
	
	if dim == 1
    error('Vertical sum operation over objects not possible for datafiles')
	elseif dim == 2
		s = zeros(size(a,1),1);
		next = 1;
		while next > 0
			[b,next,J] = readdatafile(a,next);
			s(J) = s(J) + sum(b,2);
		end
	else
		error('Illegal dimension requested')
	end

	return
