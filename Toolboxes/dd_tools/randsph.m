%RANDSPH generate objects in hypersphere
%
%    X = RANDSPH(N,D)
%
% INPUT
%   N     Number of objects
%   D     Dimensionality
%
% OUTPUT
%   X     Data matrix
% 
% DESCRIPTION
% Generate N data objects uniformly drawn from a D-dimensional hypersphere
% with zero mean and unit radius.
%
% SEE ALSO
% gendatout, chi2cdf

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function x = randsph(n,d)

% Gaussian data:
x = randn(n,d);
% Squared norms of the vectors:
nx = sum(x.*x,2);
% Make squared norms uniformly distributed:
if exist('mychi2cdf')  % necessary when I use my own copy of
							  % chi2cdf
	rx = mychi2cdf(nx,d);
else
	rx = chi2cdf(nx,d);
end
% Change uniform distribution to r^d
newrx = rx.^(2/d);

% Renormalize the original data x:
x = repmat(sqrt(newrx./nx),1,d).*x;

return

