%MEDIAN Datafile overload

function s = median(a,dim)
	
	
	if nargin < 2, dim = 1; end

	if dim == 1
		error('Vertical median of datafiles not supported')
	end
	
	s = -inf*ones(size(a,1),1);
	J = ones(1,size(a,1));
	next = 1;
	while next > 0 % indices are pixel (feature) numbers
		[b,next,K] = readdatafile(a,next);
		s(K) = median(b,2);
	end