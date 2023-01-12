%SETLABELS Reset labels of dataset or mapping
%
%   A = SETLABELS(A,LABELS,J)
%   W = SETLABELS(W,LABELS,J)
%
% INPUT
%   A          Input dataset, size [M,K]
%   W          Input mapping (classifier), size [K,C]
%   LABELS     Desired labels. M or length(J) labels for a dataset.
%              C or length(J) labels for a mapping.
% OUTPUT
%   A          Dataset with reset labels
%   W          Mapping with reset labels
%
% DESCRIPTION
% The labels of the dataset A are reset by LABELS. If supplied, the
% index vector J defines the objects for wich LABELS applies. If in
% LABELS just a single label is given all the objects defined by J
% are given that label. If LABELS is empty ([]) or NaN all the objects
% defined by J are marked as unlabeled.
%
% If A has soft labels (label type is 'soft') or has no labels but
% targets (label type is 'targets'), these soft labels or targets are
% replaced by LABELS, provided it has the right size.
%
% For soft labels and targets supplied to relabel a dataset, LABELS may be 
% supplied as a dataset of which the data are used for the soft labels or 
% targets and the feature labels are used to set LABLIST of A.
% 
% The labels stored in a classifier mapping W are assigned as feature
% labels of the resulting dataset D in case a dataset B is applied to W:
% D = A*W.
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>) 
% DATASETS, MAPPINGS, MULTI_LABELING

% Copyright: R.P.W. Duin
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% $Id: setlabels.m,v 1.8 2007/01/25 12:03:10 duin Exp $

function a = setlabels(a,labels,J)
  [m,k,c] = getsize(a);
	total = 0;
	if nargin > 2
		if max(J) > m || min(J) < 1
			error('Object indices out of range')
		end
		n = length(J);
	else
		n = m;
		J = [1:m];
		total = 1;
	end

	[a,curn] = addlablist(a); % set up multi-labels if needed and get current lablist
	lablista = getlablist(a); 

	if iscellstr(labels)
		labels = char(labels);
	end
	
	if ~isa(labels,'prdataset') && (isempty(labels) || ...
							  (isa(labels,'double') && all(isnan(labels(:)))))
        % handles setlabels(a,[]), setlabels(a,[],J), setlabels(a,NaN), etcetera
		a.nlab(J,curn) = 0;
		if nargin < 3
			a = setlablist(a,[]);
		end
		
	else
				
		if size(labels,1) == 1
			labels = repmat(labels,n,1);
		end

		if size(labels,1) ~= n
			error('Numbers of objects and labels do not match')
		end

		if ~total % replace some of the labels (given in J)
			labelsa = getlabels(a);
%			if (size(labels,2) ~= size(labelsa,2)) || ~isa(labelsa,class(labels))
%				error('Format of labels does not fit with dataset labels')
%			end

			if ~isdataset(labels) && ~isempty(a.lablist) && ~strcmp(class(labelsa),class(labels))
				error('New and old labels should be both strings, or both doubles')
			end
			if isa(labels,'char')
				if isempty(lablista)
					labelsa = repmat(char(0),n,1);
				end
				labels = char(labels,lablista);
				if size(labels,2) > size(labelsa,2)
					nblanks = size(labels,2) - size(labelsa,2);
					labelsa = [labelsa repmat(' ',m,nblanks)];
				end
				labelsa(J,:) = labels(1:length(J),:);
			else
				labelsa(J,:) = +labels; 
				% '+' is needed in case labels are targets given in a dataset
			end
			labels = labelsa;
	  end

		% All labels (old and new ones) are now in 'labels'
		
		switch a.labtype
		case 'crisp'
			if ~isa(labels,'prdataset')
				[nlaba,lablist] = renumlab(labels);
				I = matchlablist(lablist,lablista);
				if any(I==0)           % new labels found
          ;
        else                   % old lablist can be used
					J = find(nlaba > 0);
					nlaba(J) = I(nlaba(J));  % reset numeric labels
					lablist = lablista;
				end
				a.nlab(:,curn) = nlaba;
				a = setlablist(a,lablist);
			else
				error('Crisp labels cannot be supplied by a dataset, reset labtype first')
			end
		 
		case 'soft'
			if ~isa(labels,'prdataset')
				% soft label values are given in 'labels' as a double array
				if any(any(labels > 1 | labels < 0))
					error('Soft labels should be between 0 and 1')
				end
				if isempty(lablista) || size(lablista,1) ~= size(labels,2)
					% There are as many classes as 'labels' has columns
					% Generate dummy class names (numbers) if existing lablist does not fit
					a = setlablist(a,[1:size(labels,2)]');
				end
			else
				% labels (soft label values) are given in a dataset
				a = setlablist(a,labels.featlab);         % class names are the feature labels
				labels = labels.data; % targets or soft label values are in data field
			end 
			a = settargets(a,labels);
			% find numeric labels from maximum soft label values
			[mm,a.nlab(:,curlablist(a))] = max(labels,[],2); 
			
		case 'targets'
			if ~isa(labels,'prdataset')
				% target values are given in 'labels' as a double array
				%a.targets{curn} = labels;
				a = settargets(a,labels);
				if isempty(lablista) || size(lablista,1) ~= size(labels,2)
					% There are as many classes as 'labels' has columns
					% Generate dummy class names (numbers)
					a = setlablist(a,[1:size(labels,2)]');
				end
			else
			% labels (targets) are given in a dataset
				a = setlablist(a,labels.featlab); % class names are the feature label
				a = settargets(a,labels.data);
				% targets or soft label values are in the data field
			end
		end
	end
							  % reset priors?
	I = matchlablist(getlablist(a),lablista);
	if any(I==0)
		a.prior = [];
		a.cost = [];
		prwarning(4,'Prior and cost fields of dataset reset to defaults')
	end

return

