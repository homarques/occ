%CHANGELABLIST Change current label list 
%
% B = CHANGELABLIST(A,LABLISTNAME)
% B = CHANGELABLIST(A,LABLISTNUMBER)
%
% INPUT
%   A             - Dataset
%   LABLISTNAME   - Name of desired label list
%   LABLISTNUMBER - Number of desired label list (default 1)
%
% OUTPUT
%   B             - Dataset
%
% DESCRIPTION
% This command makes another label list, stored already in A by
% ADDLABLIST, the current one.
% The default label list is the first one set for A.
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% DATASETS, MULTI_LABELING, ADDLABLIST, CURLABLIST

% Copyright: R.P.W. Duin
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function a = changelablist(a,lablistname)
				
	if nargin < 2, lablistname = 1; end

	if ~iscell(a.lablist)
		if (ischar(lablistname) && strcmp(lablistname,'default')) || ...
				(~ischar(lablistname) && lablistname == 1)
			return % no mulitple labels defined and default lablist required: do nothing
		else
			error('No multiple labels set for dataset')
		end
	end

	if ischar(lablistname)
		n = strmatch(lablistname,a.lablist{end,1},'exact');
		if isempty(n)
			error('Desired label list not found')
		end
	else
		n = lablistname;
		if n >= size(a.lablist,1)
			error('Not that many label lists available')
		end
	end
	n = n(1);
		
	curn = curlablist(a);  % save current prior and costs
	a.lablist{curn,2} = a.prior;
	a.lablist{curn,3} = a.cost;
	a.lablist{curn,4} = a.labtype;
	                       % load new ones
	a.lablist{end,2} = n;
	a.prior = a.lablist{n,2};
	a.cost = a.lablist{n,3};
	a.labtype = a.lablist{n,4};
	
return
		