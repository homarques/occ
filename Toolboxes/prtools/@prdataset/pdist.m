%PDIST PRTools/dataset overload

function d = pdist(a,varargin)
if nargin > 1
  d = setdata(a,pdist2(+a,+a,varargin));
else
  d = setdata(a,pdist2(+a,+a));
end
return
