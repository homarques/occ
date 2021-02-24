%ALLCLASS Complete classifier with missing classes
%
%   W = ALLCLASS(W,LABLIST,L)

function w = allclass(w,lablist,L)

c = size(lablist,1);
if numel(L) ~= c
  v = zeros(numel(L),c);
  for j=1:numel(L)
    v(j,L(j)) = 1;
  end
  w = w*v;
  w = setlabels(w,lablist);
end