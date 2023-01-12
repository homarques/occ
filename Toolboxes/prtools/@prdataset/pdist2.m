%PDIST2 PRTools/dataset overload

function d = pdist2(a,b,varargin)
if nargin > 2
  d = setdata(a,pdist2(+a,+b,varargin));
else
  d = setdata(a,pdist2(+a,+b));
end
return
