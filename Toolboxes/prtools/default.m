%DEFAULT Assign default value to empty variable
%
%   X = DEFAULT(X,V)
%
% If X is empty it is set to V, otherwise do nothing

function x = default(x,v)

if isempty(x)
  x = v;
end