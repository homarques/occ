%STRUCT_OCTAVE This simulates the Matlab STRUCT for Octave for printing

function out = struct_octave(varargin)

if nargout > 0
  out = struct(varargin{:});
  return
end

s = struct(varargin{:});
f = fieldnames(s);
n = numel(f);

disp(' ')
for i=1:n
  item   = s.(f{i});
  classi = class(item);
  sizei  = ['%i' repmat('x%i',1,ndims(item)-1) ' '];
  switch classi
    case 'cell'
      if isempty(item)
        fprintf(['%15s: {}\n'],f{i});
      else
        fprintf(['%15s: {' sizei classi '}\n'],f{i},size(item));
      end
    case 'char'
      if size(item,1) == 1 && numel(item) < 40
        fprintf(['%15s: ''%s''\n'],f{i},item);
      else
        fprintf(['%15s: [' sizei classi ']\n'],f{i},size(item));
      end
    case 'double'
      if isempty(item)
        fprintf(['%15s: []\n'],f{i});
      elseif isscalar(item)
        fprintf(['%15s: %d \n'],f{i},item);
      elseif isvector(item) && (numel(item) <= 10 && all(item <= 1) && all(item >= 0))
        numform = sprintf('%d ',item);
        fprintf(['%15s: [' numform(1:end-1) ']\n'],f{i});
      else
        fprintf(['%15s: [' sizei classi ']\n'],f{i},size(item));
      end
    otherwise
      fprintf(['%15s: [' sizei classi ']\n'],f{i},size(item));
  end
end
  
  