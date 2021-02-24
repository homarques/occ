%DD_ROC Receiver Operating Characteristic curve 
%
%        E = DD_ROC(A,W)
%        E = DD_ROC(A*W)
%        E = A*W*DD_ROC
%
% INPUT
%   A     One-class dataset
%   W     One-class classifier
%
% OUTPUT
%   E     ROC curve
%
% DESCRIPTION
% Find for a (data description) method W the Receiver Operating
% Characteristic curve over dataset A.  The results are returned in a
% structure E, containing two fields. E.err contains the classification
% errors, E.thr contains the trhesholds for the different operating
% points.
%
% The first column of E.err gives the fraction of target objects
% rejected (false negative fraction, FN), the second column the fraction
% of outlier objects accepted (the false positive fraction, FP). 
%
% NOTE: people typically use this ROC definition: false positive FP
% (outlier accepted) on the x-axis, and true positive TP (target
% accepted) on the y-axis. You can retrieve that by using:
%   NEWE = [E(:,2) 1-E(:,1)]
% I choose to define E consistent, i.e. both numbers indicate
% 'errors'. In the routines PLOTROC and DD_AUC the variable E is
% automatically converted to get the 'standard' plots and AUC values.
%
% REFERENCE
%@article{Metz1978,
%	author = {Metz, C.E.},
%	title = {Basic principles of {ROC} analysis},
%	journal = {Seminars in Nuclear Medicine},
%	year = {1978},
%	volume = {VIII},
%	number = {4},
%	month = {October}
%}
% SEE ALSO
% plotroc, dd_auc, dd_error, simpleroc, dd_eer.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function [e, thr] = dd_roc(a,w)
% Use the same setup as testc

% When no input arguments are given, return an empty mapping
if nargin==0
	
	e = prmapping(mfilename,'fixed');
	e = setbatch(e,0); % do not use batches!
	e = setname(e,'ROC');

elseif nargin == 1

	% Now we should have a mapped dataset, so the real work is done!

	% Store the fact that we are making a ROC curve
	e.type = 'roc';

	% for evaluation, we need both target and outlier objects:
	if ~isocset(a)
		error('I need an OC dataset for computing the ROC curve.');
	end
	[It,Io] = find_target(a);
	if isempty(It)
		error('Dataset A does not contain target objects');
	end
	if isempty(Io)
		error('Dataset A does not contain outlier objects');
	end
   e.N = [length(It), length(Io)];

	% get the labels of A:
	truelab = zeros(size(a,1),1);
	truelab(It) = 1;

	% check if we have sane results:
	if ~all(isfinite(+a))
		% only keep the outputs which have finite values:
		I = all(isfinite(+a),2);
		a = a(I,:);
		if isempty(a)
			warning('dd_tools:AllNonfiniteOutputs',...
				'ALL classifier outputs are non-finite!');
			a = prdataset([1 1; 1 1]);
			truelab = [0;1];
			a = setfeatlab(a,{'target', 'outlier'});

		else
			warning('dd_tools:NonfiniteOutputs',...
				'Some strange (non-finite) classifier outputs: can you check your classifier?');
		end
	end
	% check if the output is normalized (important for classifiers that
	% output just a class-conditional density: for these situations the
	% raw outputs cannot be compared between different objects:
	%(if only a single output exist no normalisation is
	%needed/possible)
	if (size(a,2)>1 )
		% check if we are working with a one-class classifier with a fixed
		% threshold
		if var(a(:,'outlier'))>1e-6
			if any(abs(sum(a,2)-1)>1e-6)
				warning('dd_tools:NonNormalizedOutputs',...
				'Some non-normalized outputs found: can you check your classifier?');
			end
		end
	end

	% store the operating point for later:
	% First check if we are dealing with a mapping, or a classifier:
	fl = getfeatlab(a);
	if size(fl,1)<2 % it is a mapping, so no OP available
		e.op = [];
	else % it is a classifier, we can just apply dd_error
		e.op = dd_error(a);
	end

	% first find out where the output for the target objects are stored:
	tcolumn = [];
	if ~isempty(fl) % we can only find the target feature when feature
		             % labels are defined
		tcolumn = strmatch('target',fl);
	end
	if isempty(tcolumn)
		warning('dd_tools:NoTargetFeature',...
				  'dd_roc cannot find the target feature, using feature 1.');
		tcolumn = 1;
	end
	% and now extract the required column 'resemblance to target set':
	a = +a(:,tcolumn);

	% now the real computation is done:
	[err, thr] = simpleroc(a,truelab);
	e.err = err;

	% Find the errors and the thresholds between the points on the curve:
	derr = diff(err)/2;
	e.thrcoords = [err(1,:); err(1:(end-1),:)+derr; err(end,:)];
	dthr = diff(thr)/2;
	if ~isempty(dthr) % in some cases there is just 1 threshold value
		               % defined :-( (sigh)
		e.thresholds = [thr(1); thr(1:(end-1))+dthr; thr(end)];
	else
		e.thresholds = [thr(1); thr(end)];
	end

else

	% Separate mapping and dataset are given, so we have to map the data
	% first:
	ismapping(w);
	istrained(w);

	e = feval(mfilename,a*w);

end

return
