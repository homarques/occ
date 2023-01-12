%GENDATW Sample dataset by given weigths
%
%   B = GENDATW(A,V,N)
%
% INPUT
%   A    Dataset
%   V    Vector with weigths for each object in A
%   N    Number of objects to be generated (default size A);
%
% OUTPUT
%   B    Dataset
%
% DESCRIPTION
% The dataset A is sampled using the weigths in V as a prior distribution.

function b = gendatw(a,v,n)

isdataset(a);
if nargin < 3, n  = size(a,1); end

v = v./sum(v);
if any(v<0)
    error('Weights should be positive');
end

mins = 0;
nn = 0;

while(mins < 2)             % run until at least two classes are found
	N = genclass(n,v);        % sample the objects according to v
	L = [];
  for j=1:max(N)            % find selected ones
    L = [L find(N >= j)];   % allow for multiple selections
  end
	b = a(L,:);
	mins = sum(classsizes(b) > 1);
	nn = nn + 1;
	if nn > 100
		error('PRTools:gendatw:SmallSet','Problems with weighted subsampling: classes have disappeared. Please enlarge training set.')
	end
end

return

