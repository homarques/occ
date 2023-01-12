%ARGMIN Returns the minimum of rows, columns of of two data matrices
%
%   J = ARGMIN(A,B)
%   J = ARGMIN(A,[],DIM)
%   J = A*ARGMIN(DIM)
%
% DESCRIPTION
% In case of two data matrices A and B of the same size, ARGMIN returns the
% a matrix J of integers 1 and 2 pointing for every element to the smallest
% of the two matrices.
%
% In case of a single data matrix A the indices of the minimum element in
% every column (DIM = 1) or every row (DIM) is returned in the vector J.
%
% SEE ALSO
% ARGSORT, ARGMAX, SORTIND

function r = argmin(varargin)

  argin = shiftargin(varargin,'scalar',1);
  argin = shiftargin(argin,'scalar',2);
  argin = setdefaults(argin,[],[],1);
  if mapping_task(argin,'definition')
    % mapping definition
    r = define_mapping(argin,'fixed');
  else
    [a,b,dim] = deal(argin{:});
    if isempty(b)
      [~,r] = min(a,b,dim);
    else
      r = real(a>b)+1;
    end
  end
