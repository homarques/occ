function [post, NlogL] = posterior(obj,X)
% POSTERIOR Posterior probability of components given data.
%    POST = POSTERIOR(OBJ,X) returns POST, a matrix containing
%    estimates of the posterior probability of the components in
%    gmdistribution OBJ given points in X. X is an N-by-D data matrix. Rows
%    of X correspond to points, columns correspond to variables. POST(I,J)
%    is the posterior probability of point I belonging to component J,
%    i.e., Pr{Component J | point I}. 
%
%    POSTERIOR treats NaNs as missing data. Rows of X with NaNs are
%    excluded from the computation.
%
%    [POST,NLOGL] = POSTERIOR(OBJ,X) returns NLOGL, the negative likelihood
%    of the data X given the model contained in OBJ.
%
%    See also GMDISTRIBUTION/CLUSTER, GMDISTRIBUTION/MAHAL,.

%    Copyright 2007 The MathWorks, Inc.


% Check for valid input

narginchk(2,2);
checkdata(X,obj);

%remove NaNs
wasnan=any(isnan(X),2);
hadNaNs=any(wasnan);
if hadNaNs
    warning(message('stats:gmdistribution:posterior:MissingData'));
    X = X( ~ wasnan,:);
end

covNames = { 'diagonal','full'};
CovType = find(strncmpi(obj.CovType,covNames,length(obj.CovType)));
log_lh = wdensity(X,obj.mu, obj.Sigma, obj.PComponents, obj.SharedCov, CovType);
[ll, post] = estep(log_lh);

NlogL=-ll;

if hadNaNs
    post= dfswitchyard('statinsertnan',wasnan,post);

end
