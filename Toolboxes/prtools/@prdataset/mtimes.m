%MTIMES Dataset overload of *
%
%    C = A*B
%
% This routines handles the dataset multiplication in case A or B is
% a dataset and none of these is a mapping. A or B may be a cell array
% of datasets as well as a scalar. 

% $Id: mtimes.m,v 1.4 2007/03/22 07:45:54 duin Exp $

function varargout = mtimes(a,b)
		
varargout = cell(1,nargout);
if isa(a,'double')
  if isscalar(a) 
    varargout{1} = b*a;
  else % some matrix multiplication desired
    varargout{1} = a*b.data;
  end
elseif isa(a,'cell')
	if min(size(a)) ~= 1
		error('Only one-dimensional cell arrays are supported')
	end
	c = cell(size(a));
	for j=1:length(a)
		c{j} = a{j}*b;
  end
  if nargout == 0
    c
  elseif nargout == 1
    varargout{1} = c;
  elseif nargout == numel(c)
    varargout = c;
  else
    for j=1:min(nargout,numel(c))
      varargout{j} = c{j};
    end
  end
elseif isa(b,'double')
  d = a.data*b;
  varargout{1} = setdata(a,d);
elseif isa(b,'cell')
	if min(size(b)) ~= 1
		error('Only one-dimensional cell arrays are supported')
	end
	c = cell(size(b));
	for j=1:length(b)
		c{j} = a*b{j};
	end
  if nargout == 0
    c
  elseif nargout == 1
    varargout{1} = c;
  elseif nargout == numel(c)
    varargout = c;
  else
    for j=1:min(nargout,numel(c))
      varargout{j} = c{j};
    end
  end
elseif isa(b,'prmapping')
  % due to a bug in Octave we are here instead of in @prmapping/mtimes
  % so we do here what should have been done there
  if (nargout >= 1)
		[varargout{:}] = prmap(a,b);
	else
		prmap(a,b)
	end
else
  d = a.data * b.data;
  varargout{1} = setdata(a,d,b.featlab);
end
return
