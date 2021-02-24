%DD_SETFN Set the threshold to a specific FN rate
%
%     V = DD_SETFN(W,A,FN)
%
% INPUT
%   W    One-class classifier
%   A    One-class dataset
%   FN   False-negative rate
%
% OUTPUT
%   V    Updated one-class classifier
%
% DESCRIPTION
% The data of classifier W is copied to classifier V, only the
% threshold value is changed to achieve the False Negative rate FN
% on dataset A.
%
% SEE ALSO
% dd_error, dd_roc, dd_fp

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function v = dd_setfn(w,a,thr)
if ~isocc(w)
	error('dd_setfn: I need a one-class classifier to set the threshold');
end
if ~isocset(a)
	error('dd_setfn: I should have a OC-dataset to set the threshold');
end
if thr<0 || thr>1
	error('dd_setfn: the FN rate should be between 0 and 1.');
end
% find the threshold on the target data:
a = target_class(a);
if isempty(a)
	error('dd_setfn: I cannot find target data in the dataset.');
end

% Get the output for the target data:
out = a*w;

% Check if we have distance based output:
featdom = getfeatdom(out);
if ~isempty(featdom) && ~isempty(featdom{1}) && ~isempty(featdom{2}) && ...
	all(featdom{1}(:)==[-inf;-inf; 0; 0]) && all(featdom{2}(:)==[-inf; -inf;0; 0])
	% we are dealing with a distance-based one-class classif.
	thr = -dd_threshold(out(:,'target'),thr);
else
	thr = dd_threshold(out(:,'target'),thr);
end

% Change the threshold and store it:
W = w.data;
W.threshold = thr;
v = setdata(w,W);

return
