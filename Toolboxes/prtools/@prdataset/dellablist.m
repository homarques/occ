%DELLABLIST Delete a label list from dataset
%
%	B = DELLABLIST(A,LABLISTNAME)
%	B = DELLABLIST(A,LABLISTNUMBER)
%
% INPUT
%   A              - Dataset
%   LABLISTNAME    - String to identify the label list to be deleted
%   LABLISTNUMBER  - Number to identify the label list to be deleted
%
% OUTPUT
%   B              - Dataset
%
% DESCRIPTION
% In the multi-label system for datasets, additional labellings can be
% added by ADDLABELS. This is stored in the LABLIST and NLAB fields of
% the dataset. By this command, DELLABLIST such a labeling can be removed.
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% DATASETS, MULTI_LABELING, ADDLABELS, ADDLABLIST, CHANGELABLIST, CURLABLIST

% Copyright: R.P.W. Duin
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function a = dellablist(a,lablistname)
				
	if ~iscell(a.lablist) || size(a.lablist,1) == 2
		error('Last label list cannot be deleted')
	end
	
	[curn,curname] = curlablist(a);   % get current lablist
	a = changelablist(a,lablistname);
	n = curlablist(a);          % lablist to be deleted
	if curn == n                % compute new current lablist number
		newn = 1;                 % return to default if current is to be deleted
	elseif curn < n
		newn = curn;
	else
		newn = curn-1;
	end
	a.lablist(n,:) = [];
	a.lablist{end,1}(n,:) = [];
	a.lablist{end,2} = newn;
	a.nlab(:,n) = [];
		
	
	
return
	
	

