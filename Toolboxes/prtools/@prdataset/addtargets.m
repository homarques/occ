%ADDTARGETS Add a new targets to an existing dataset
%
%	[B,LABLISTNUMBER] = ADDTARGETS(A,TARGETS,LABLISTNAME)
%
% INPUT
%   A              - Dataset
%   TARGETS        - Array or dataset with targets
%   LABLISTNAME    - String to identify the new set of targets
%
% OUTPUT
%   B              - Dataset
%   LABLISTNUMBER  - Number for the new label list
%
% DESCRIPTION
% This adds a new set of targets to the given dataset A. It has thereby a
% multiple labeling and/or targets. The new targets are immediately activated
% and made the current one. See MULTI_LABELING for a description of the 
% multiple labeling/target system. See ADDLABLIST for implementation details.
% Desired target sets or labellings may be set by CHANGELABLIST using the 
% LABLISTNUMBER or LABLISTNAME. The original, first labeling of a dataset has 
% LABLISTNUMBER = 1 and LABLISTNAME = 'default'.
%
% A defined target set can be removed by DELLABLIST.
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% DATASETS, MULTI_LABELING, ADDLABLIST, ADDLABELS, CHANGELABLIST, DELLABLIST

% Copyright: R.P.W. Duin
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function [a,n] = addtargets(a,targets,name)
				
	if nargin < 3, name = []; end
		
	if size(targets,1) ~= size(a,1)
		error('Numbers of objects and targets do not match')
	end
	
	if isdataset(targets) 
		lablist = getfeatlab(targets);
	else
		lablist = [1:size(targets,2)]';
	end
	[a,n] = addlablist(a,lablist,name,'targets');
	a.labtype = 'targets';
	a = settargets(a,targets);
	
return
