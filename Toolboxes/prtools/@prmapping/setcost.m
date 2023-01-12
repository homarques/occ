%SETCOST Reset classification cost matrix of mapping
%
%   W = SETCOST(W,COST,LABLIST)
%
% The classification cost matrix of the dataset W is reset to COST.
% W has to be a trained classifier. COST should have size [C,C+1],
% if C is the number of classes assigned by W.
% COST(I,J) are the costs of classifying an object of class I
% as class J. Column C+1 generates an alternative reject class and
% may be omitted, yielding a size of [C,C].
% An empty cost matrix, COST = [] (default) is interpreted as
% COST = ONES(C) - EYE(C) (identical costs of misclassification).
%
% In LABLIST the corresponding class labels may be supplied.
% LABLIST may have only class names of the existing labels assigned
% by W, stored in W.LABELS.

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function w = setcost(w,par,lablist)
				
istrained(w);
c = size(w,2);
if isvaldfile(par) % call like w = setcost(w,a), so take cost from a
	cost = par.cost;
	lablist = par.lablist;
elseif ismapping(par); % call like w = setcost(w,v), for combiners, take cost from v
	cost = par.cost;
	lablist = par.labels;
else
	cost = par;
end
if ~isempty(cost)
	if any(size(cost) ~= [c,c+1]) && any(size(cost) ~= [c,c])
		cc = num2str(c);
		c1 = num2str(c+1);
		error(['Size of cost matrix should be [' cc ',' cc '] or [' cc ',' c1 ']'])
	end
end

if nargin > 2 && ~isempty(lablist)
	if size(lablist,1) ~= size(cost,2)
		error('Wrong number of labels supplied')
	end
	I = matchlablist(w.labels,lablist);
	J = [1:size(lablist,1)];
	J(I) = []; % find label in lablist not in dataset
	cost = [cost(I,I) cost(:,J)];
	w = setlabels(w,lablist([I;J],:));
end

w.cost = cost;

