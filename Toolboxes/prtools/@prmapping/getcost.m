%GETCOST Get classification cost matrix
%
%  [COST,LABLIST] = GETCOST(W)
%
% Returns the classification cost matrix as set in the classifier W.
% An empty cost matrix is interpreted as equal costs for misclassification.
% In that case COST = ONES(C+1) - EYE(C+1) is returned, if C is the number
% of classes. Row C+1 and column C+1 in COST refer to unlabeld objects.
% In LABLIST the class labels are returned.
% Getcost will return [] when no costmatrix is defined.
%
% If A has target labels an error is returned as in that case no classes
% and thereby no costs are defined.
%
% See MAPPINGS

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [cost,lablist] = getcost(w)
		
% Get the cost-info from the mapping, the cost matrix and the labels:
cost = w.cost;
% We have to use this way around, because it is possible to have an
% empty cell array, which has a size of [1 0]. This screws up all
% the rest, because then suddenly c=1. BAD Matlab!
if ~isempty(w.labels)
	c = size(w.labels,1);
else
	c = 0;
end

if c==0 % we have a mapping without labels, so no costmatrix is
	% available and we immediately return:
	lablist = {};
	return
end

% If labels are given, we may want to return the uniform cost:

if isempty(cost)
	cost = ones(c) - eye(c);
end
lablist = w.labels;

return
