%GETCOST Get classification cost matrix
%
%  [COST,LABLIST] = GETCOST(A)
%
% Returns the classification cost matrix as defined for the dataset A.
% An empty cost matrix is interpreted as equal costs for misclassification.
% In that case COST = ONES(C+1) - EYE(C+1) is returned, if C is the number
% of classes. Row C+1 and column C+1 in COST refer to unlabeld objects.
% In LABLIST the class labels are returned.
%
% If A has target labels an error is returned as in that case no classes
% and thereby no costs are defined.
%
% See DATASETS

% Copyright: R.P.W. Duin and D.M.J. Tax, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: getcost.m,v 1.3 2006/09/26 12:49:54 duin Exp $

function [cost,lablist] = getcost(a)
		
% Get the cost-info from the dataset, the cost matrix and the lablist:
cost = a.cost;
% We have to use this way around, because it is possible to have an
% empty cell array, which has a size of [1 0]. This screws up all
% the rest, because then suddenly c=1. BAD Matlab!

lablist = getlablist(a);
if ~isempty(lablist)
	c = size(lablist,1);
else
	c = 0;
end

if c==0 % we have a dataset without lablist, so no costmatrix is
	% available and we immediately return:
	lablist = {};
	return
end

% If a lablist is given, we may want to return the uniform cost:

if isempty(cost)
	switch a.labtype
    case {'crisp','soft'}
		%The unlabeled data for now:
		cost = ones(c) - eye(c);
    case 'targets'
		error('No classification costs defined for dataset with label type ''targets''')
    end
end

return
