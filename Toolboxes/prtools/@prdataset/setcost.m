%SETCOST Reset classification cost matrix of dataset
%
%   A = SETCOST(A,COST,LABLIST)
%
% The classification cost matrix of the dataset A is reset to COST.
% COST should have size [C,C+n], n >= 0, if C is the number of classes.
% COST(I,J) are the costs of classifying an object of class I
% as class J. Columns C+j generate an alternative reject classes and
% may be omitted, yielding a size of [C,C].
% An empty cost matrix, COST = [] (default) is interpreted as
% COST = ONES(C) - EYE(C) (identical costs of misclassification).
%
% In LABLIST the corresponding class labels may be supplied.
% LABLIST may have only class names of the existing classes in A.
% Reset class names first by SETLABLIST if necessary.
%
% Alternatively, for classification matrices, LABLIST may refer to
% the class names stored in the feature labels. This should be used
% with care as it may disturb the existing lableling of A.
%
% If LABLIST is not given, the order defined by the existing LABLIST
% for A (determined by [NLAB,LABLIST] = renumlab(LABELS)) is used.

% Copyright: R.P.W. Duin, D.M.J. Tax, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: setcost.m,v 1.3 2006/09/26 12:51:15 duin Exp $

function a = setcost(a,cost,lablist)
   

   if strcmp(a.labtype,'targets') && ~isempty(cost)
      error('Cost handling not defined for dataset with label type ''targets''')
   end

   [m,k,c] = getsize(a);

   if ~isempty(cost)
      if (size(cost,1) ~= c && size(cost,1) ~= k)
	 error([prnewline 'The number of rows in the cost matrix should match the number' ...
		prnewline 'of classes or the number of features'])
      end
      if size(cost,2) < size(cost,1)
	 error([prnewline 'Number of columns in cost matrix should be at least number of rows'])
      end
   end

	if (nargin>2) && (~isempty(lablist))
		% Match the costmatrix to the dataset:
		if (size(a,2) == size(cost,1))
			% the features should match the cost
			[cost,lablist] = matchcost(a.featlab,cost,lablist);
		else
			% the class-labels should match the cost
			lablista = getlablist(a);
			[cost,lablist] = matchcost(lablista,cost,lablist);
		end
		a = setlablist(a,lablist);
	end

	% Store the result:
   a.cost = cost;
	 
	 if iscell(a.lablist)
		 n = a.lablist{end,2};
		 a.lablist{n,3} = a.cost;
	 end
	 
return
