% DD_AVPREC compute the average precision
%
%      AP = DD_AVPREC(E,BND)
%
% INPUT
%   E     Precision-recall graph
%   BND   Lower and upper bound for integration (default=[0 1])
%
% OUTPUT
%   AP    Average precision
%
% DESCRIPTION
% Compute the average precision from a precision-recall curve (as obtained
% by dd_prc). We use the estimator:
%
%   AP = 1/N sum_i^N prec(y_i)
%
% where y_i, i=1...N are the positive objects.
% When the BND is defined, then the sum runs from BND(1) recall to
% BND(2) recall, and the precisions are averaged.
%
% REFERENCES 
%Area under the Precision-Recall Curve: Point Estimates and Confidence
% Intervals, Boyd, Kendrick and Eng, KevinH. and Page, C.David, Machine
% Learning and Knowledge Discovery in Databases, vol 8190, 2013, pg.
% 451-466.
%
% SEE ALSO
% dd_error, dd_prc, dd_auc.
%

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function err = dd_avprec(e,bnd)
if nargin<2
   bnd = [];
end

% First check if we are dealing with an PrecRecall structure as it is
% delivered by dd_prc:
if isa(e,'struct')
	if ~isfield(e,'type')
		error('The curve should be a precision-recall curve (by dd_prc).');
	end
	if ~strcmp(e.type,'prc')
		error('The curve should be a precision-recall curve, no ROC curve.');
	end
	if isfield(e,'err')
		e = e.err;
	else
		error('E seems to be a struct, but does not contain an E.err field');
	end
else
	
	%error('Please supply a valid precision-recall curve (by dd_prc)');
end

% the first column has the precision, the second column has the recall
if isempty(bnd)
   err = nanmean(e(:,1));
else
   N = size(e,1);
   bnd = round(bnd*(1-N)+N);
   err = nanmean(e(bnd(2):bnd(1),1));
end

return
