%CONSISTENT_OCC
%
%     W = CONSISTENT_OCC(X,NAME,FRACREJ,RANGE,NRFOLDS)
%     W = X*CONSISTENT_OCC([],NAME,FRACREJ,RANGE,NRFOLDS)
%     W = X*CONSISTENT_OCC(NAME,FRACREJ,RANGE,NRFOLDS)
%
% INPUT
%   X        Dataset
%   NAME     Name of a one-class classifier (default = 'gauss_dd')
%   FRACREJ  Fraction of target objects rejected (default = 0.1)
%   RANGE    List of values tried for the hyperparameter (default =
%            linspace(0,0.5,11) )
%   NRFOLDS  Nr of folds in the crossvalidation (default = 10)
%
% OUTPUT
%   W        One-class classifier with optimized hyperparameter
%
% DESCRIPTION
% Optimize the hyperparameters of method W. W should contain the
% (string) name of a one-class classifier. Using crossvalidation on
% dataset X (containing just target objects!), this classifier is
% trained using the target rejection rate FRACREJ and the values of
% the hyperparameter given in RANGE. The hyperparameters in RANGE
% should be ordered such that the most simple classifier comes
% first. New hyperparameters (for more complex classifiers) are used
% until the classifier becomes inconsistent. Per default
% NRBAGS-crossvalidation is used.
%
% An example for kmeans_dd, where k is optimized:
%    w = consistent_occ(x,'kmeans_dd',0.1, 1:20)
%    w = consistent_occ(x,'svdd',0.1, scale_range(x))
%
%     W = CONSISTENT_OCC(X,W,FRACREJ,RANGE,NRBAGS,P1,P2,...)
%
% Finally, some classifiers require additional parameters, they
% should be given in P1,P2,... at the end.
%
% See also: scale_range, dd_crossval

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function [data_targets] = perturbation(x, nrinst, perc)

if nargin < 3 || isempty(perc), perc = 0.9; end
if nargin < 2 || isempty(nrinst), nrinst = 20; end
if nargin < 1 || isempty(x)
	error('Incorrect call to Data Perturbation: Empty dataset');
end

%make sure we have a OneClass dataset
x = target_class(x);

%train linear SVDD
[n, d] = size(x);
w = linsvdd((oc_set(x)));
x = +x;

%increase the magnitude of the noise while the outlier acceptance is greater than 0.5
noise = 0.05;
fracrej = 1;
while fracrej > perc
	%increase the noise magnitude
	noise = noise + 0.05;
	perf = zeros(nrinst, 1);
	data_targets = cell(nrinst, 1);
	
	%generate nrinst perturbed data
	for i = 1:nrinst
		data_targets{i} = zeros(n,d);
		for j = 1:d
			data_targets{i}(:,j) = x(:,j) + normrnd(0, (noise*(max(x(:,j))-min(x(:,j)))), [n, 1]); %normrnd(0, (noise*std(x(:,j))), [n, 1]);
		end
		data_targets{i} = gendatoc([], data_targets{i});
		err = dd_error(data_targets{i}, w);
		perf(i) = err(2);
	end
	[~, k] = sort(perf);
	data_targets = data_targets(k(1:10));
	fracrej = mean(perf(k(1:10)));

end

return