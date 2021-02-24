% DD_PRECISIONATK precision at k
%
%   PERF = DD_PRECISIONATK(D,K)
%   PERF = A*W*DD_PRECISIONATK([],K)
%   C = DD_PRECISIONATK(D)
%
% INPUT
%   D      One-class dataset (output as D = A*W)
%   K      K-level
%
% OUTPUT
%   PERF   Precision at K
%   C      Precision versus rank curve
%
% DESCRIPTION
% Compute the precision at K for dataset D (output of a classifier like
% D=A*W).
% If no K is supplied, the full curve of precision vs. rank is returned.
%
% SEE ALSO
% dd_error, dd_roc.
%

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function err = dd_precisionatk(e,k)

if (nargin<2)
	k = [];
end
if (nargin<1) || isempty(e)
   err = prmapping(mfilename,'fixed',k);
   err = setbatch(err,0); % do NOT process in batches!!
   err = setname(err,'Precision@K');
   return
end

% First check if we have a dataset as input:
if ~isdataset(e)
	error('I expect a dataset D');
end

% Do we need precision at k, or the full curve?
if isempty(k)
   N = size(e,1);
   [~,I]=sort(+e(:,'target'),'descend');
   J = istarget(e);
   p = cumsum(J(I))./(1:N)';
   err.type = 'precisionatk';
   err.err = [(1:N)' p(:)];
   err.thresholds = [];
else
   if size(e,1)<k
      error('Dataset is too small for the given K.');
   end

   % find the top K positive objects
   labels = istarget(e);
   out = e(:,'target');
   [sout,I] = sort(+out,'descend');
   err = mean(labels(I(1:k)));
end

return
