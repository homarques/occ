%SORTIND Returns the indices in the sorted array
%
%   J = SORTIND(A,DIM)
%
% DESCRIPTION
% SORTIND returns of every element of the data matrix A its index in the
% sorted array along the direction DIM. 
%
% SEE ALSO
% ARGMIN, ARGMAX, ARGSORT

function r = sortind(varargin)

  argin = shiftargin(varargin,'scalar',1);
  argin = setdefaults(argin,[],1);
  if mapping_task(argin,'definition')
    % mapping definition
    r = define_mapping(argin,'fixed');
  else
    [a,dim] = deal(argin{:});
    [~,r] = sort(a,dim);
    [~,r] = sort(r,dim);
  end
