%MIN Dataset overload

% $Id: min.m,v 1.3 2007/03/22 07:45:54 duin Exp $

function [s,I] = min(a,b,dim)
			if nargin == 1
		[s,I] = min(a.data);
	elseif nargin == 2
		if ~isa(a,'prdataset')
			s = b;
			d = min(a,b.data);
		elseif ~isa(b,'prdataset')
			s = a;
			d = min(a.data,b);
		else
			s = a;
			d = min(a.data,b.data);
		end
		s = setdata(s,d);
	elseif nargin == 3
		if ~isempty(b)
			error('min with two matrices to compare and a working dimension is not supported')
		end
		if dim == 1
			[s,I] = min(a.data,[],1);
		elseif dim == 2
			[s,I] = min(a.data,[],2);
			%s = setdata(a,s,'min'); % just a single feature with minima
		else
			error('Dimension should be 1 or 2')
		end
	end
return
