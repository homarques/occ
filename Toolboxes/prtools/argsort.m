%ARGSORT Returns the indices of the sorted array
%
%   J = ARGSORT(A,DIM)
%
% DESCRIPTION
% ARGSORT sorts the datamatrix A in the direction DIM (default DIM = 1) and
% return the indices of the sorted elements in the original matrix.
%
% SEE ALSO
% ARGMIN, ARGMAX, RANKVAL

function r = argsort(varargin)

  argin = shiftargin(varargin,'scalar',1);
  argin = setdefaults(argin,[],1);
  if mapping_task(argin,'definition')
    % mapping definition
    r = define_mapping(argin,'fixed');
  else
    [a,dim] = deal(argin{:});
    [~,r] = sort(a,dim);
  end
