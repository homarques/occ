%STRUCT overload for Octave purposes

function out = struct(varargin)

if isoctave && nargout == 0
  struct_octave(varargin{:});
else
  out = builtin('struct',varargin{:});
end
  