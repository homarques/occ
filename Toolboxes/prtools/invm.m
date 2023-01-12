%INVM Inverse mapping
%
%   W = INVM(A,B)
%   W = A*INVM(B)
%
% Find an affine mapping W between de datasets A and B such that B=A*W

function w = invm(a,b)

if isdataset(a) && nargin == 1
  b = a; a = [];
end
if isempty(a)
  w = prmapping(mfilename,'untrained',b);
else
  v = prpinv(a)*b;
  %w = affine(v,mean(b),[]);
  w = affine(v,[],[]);
  offset = +mean(a*w-b);
  w = affine(v,-offset,[]);
  w = setname(w,'Pseudo_inverse');
end