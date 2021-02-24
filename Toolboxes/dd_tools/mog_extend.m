%MOG_EXTEND Extend a MoG with one cluster
%
%     W = MOG_EXTEND(W,X,[],MAXITER)
%     W = MOG_UPDATE(W,X,N,MAXITER)
%
% INPUT
%   W          Mixture model
%   X          One-class dataset
%   N          Indicator where to add a cluster (default = [1 0])
%   MAXITER    Number EM training updates to make (default = 25)
%
% OUTPUT
%   W          Extended mixture model
%
% DESCRIPTION
% Extend a Mixture of Gaussians model W to data X with one extra cluster
% for the target class. Maximally MAXITER EM-updates are made.
%
% If input parameter N is given, you can specify if it should be for the
% target, outlier or both classes:
%   N = [0 1] : only extra outlier cluster
%   N = [1 1] : both target and outlier cluster.
%
% SEE ALSO
% mog_dd, mog_init, mog_P, mog_update

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function w = mog_extend(w,x,n,maxiter)
if nargin<4
	maxiter = 25;
end
if nargin<3 || isempty(n)
	n = [1 0];
end

% initialize
if length(n)<2
	n = [n 0];
end

% get data:
dat = w.data;
[xt,xo] = target_class(x);

% update the target class clusters:
if (n(1)>0) && ~isempty(xt)
	[dat.mt,dat.ict,dat.pt] = mogEMextend(+xt,dat.covtype,dat.mt,dat.ict,dat.pt,maxiter);
end
% update the outlier class clusters:
if (n(2)>0) && ~isempty(xo)
	[dat.mo,dat.ico,dat.po] = mogEMextend(+xo,dat.covtype,dat.mo,dat.ico,dat.po,maxiter);
end

% store it again:
w.data = dat;

return

