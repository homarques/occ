%ADDLABELS Add a new labeling to an existing dataset
%
%	[B,LABLISTNUMBER] = ADDLABELS(A,LABELS,LABLISTNAME)
%
% INPUT
%   A              - Dataset
%   LABELS         - Vector or character array with labels
%   LABLISTNAME    - String to identify the new labeling
%
% OUTPUT
%   B              - Dataset
%   LABLISTNUMBER  - Number for the new label list
%
% DESCRIPTION
% This adds a new labeling to the given dataset A. It has thereby a
% multiple labeling. The new labeling is immediately activated and made the
% current one. See MULTI_LABELING for a description of the multiple labeling
% system. See ADDLABLIST for implementation details.
% Desired labellings may be set by CHANGELABLIST using the LABLISTNUMBER 
% or LABLISTNAME. The original, first labeling of a dataset has 
% LABLISTNUMBER = 1 and LABLISTNAME = 'default'.
%
% Use SETPRIOR and SETCOST to set priors and costs for the new labeling.
% A defined labeling can be removed by DELLABLIST.
% This multiple labeling system is implemented for crisp labels only.
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% DATASETS, MULTI_LABELING, ADDLABLIST, CHANGELABLIST, DELLABLIST, SETPRIOR

% Copyright: R.P.W. Duin
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function [a,n] = addlabels(a,labels,name)
				
	if nargin < 3, name = []; end
	
  %	islabtype(a,'crisp','soft');
	if size(labels,1) == 1
		labels = repmat(labels,size(a,1),1);
	end
	
	if size(labels,1) ~= size(a,1)
		error('Numbers of objects and labels do not match')
	end
	
	if isdataset(labels) % soft labels
		lablist = getfeatlab(labels);
		[a,n] = addlablist(a,lablist,name,'soft');
		a.labtype = 'soft';
		a = setlabels(a,labels);
	else
		[nlab,lablist] = renumlab(labels);
		[a,n] = addlablist(a,lablist,name,'crisp');
		a.labtype = 'crisp';
		a.nlab(:,n) = nlab;
	end
	
return
