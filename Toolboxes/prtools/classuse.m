%CLASSUSE Get indices of used classes
%
%   N = CLASSUSE(A,M)
%
% INPUT
%   A   Dataset
%   M   Integer, minimum desired class size, default 1.
%
% OUTPUT
%   N   Indices of classes with M or more objects

function N = classuse(a,m)

if nargin < 2, m = 1; end
isa(a,'prdataset');

L = classsizes(a);
N = find(L >= m);

return
