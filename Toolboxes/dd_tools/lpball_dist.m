%LPBALL_DIST Maximum Lp distance to a mean
%
%     [F,G,H] = LPBALL_DIST(M,X,P,FRAC)
%
% INPUT
%   M     Mean
%   X     Data matrix
%   P     Degree P
%   FRAC  Fraction of data to be used
%
% OUTPUT
%   F     Maximum distance
%   G     Gradient of maximum
%   H     Hessian of maximum
%
% DESCRIPTION
% Compute the maximum distance of objects X to the mean M, using Lp
% distances with P. To make the distance a bit more robust, just a
% fraction FRAC of the data is taken into account. The distance is
% returned in F, the derivative in G and the Hessian in H.
%
% SEE ALSO
% lpball_dd

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function [f,g,h] = lpball_dist(m,x,p,frac)
if nargin<4
	frac = [];
end

n = size(x,1);
d = sum( abs(x - repmat(m,n,1)).^p ,2);

if isempty(frac)
	[f,I] = max(d);
else
	[f,I] = dd_threshold(d,1-frac);
end

if nargout>1
	d = x(I,:) - m;
	g =p*sign(d).*(abs(d).^(p-1));

	if nargout>2
		h = diag(p*(p-1)*sign(d).*(abs(d).^(p-2)));
	end
end


return
