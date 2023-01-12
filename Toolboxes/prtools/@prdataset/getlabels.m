%GETLABELS Get labels or soft labels of a dataset
%
%	  [LABELS,LABLIST] = GETLABELS(A,TYPE,LABLISTNAME)
%
% INPUT
%  A            Dataset
%  TYPE         Label type for conversion, e.g. 'crisp' or 'soft'. 
%               Default: no conversion.
%  LABLISTNAME  Desired lablist, default: present on of A.
%
% OUTPUT
%  LABELS
%  LABLIST
%
% DESCRIPTION
% Get the labels (crisp or soft) of the objects in the dataset A.
% If A has target labels they are converted to soft labels first. 
% See SETLABTYPE for conversion rules.
% LABLIST is the unique set of labels of A and is thereby identical to
% the class names of A.
%
% TYPE = 'soft' forces the return of soft labels after conversion (if 
% necessary). This is identical to GETTARGETS(A,'soft').
% Note that soft labels are not names, but memberships to all classes.
% If A has crisp labels or target labels they are converted to soft
% labels first. See SETLABTYPE for conversion rules.
% 
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% SETLABTYPE, GETTARGETS, SETLABELS, SETTARGETS, MULTI_LABELING

% Copyright: R.P.W. Duin
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% $Id: getlabels.m,v 1.5 2007/06/26 10:23:00 duin Exp $

function [labels,lablist] = getlabels(a,type,lablistname)
		[m,k] = size(a);
if nargin == 3
	a = changelablist(a,lablistname);
end
a = addlablist(a); % convert to new lablist definition when needed
lablist = getlablist(a);

if nargin > 1 && ~isempty(type)  % convert label type if desired
	a = setlabtype(a,type);
	prwarning(4,'setting labels to specified type');
end

if strcmp(a.labtype,'targets') % Dataset with target labels has no object labels
	a = setlabtype(a,'crisp');   % Convert it first.
	prwarning(4,'setting labels to crisp type');
end

switch a.labtype
case 'crisp'
	curn = curlablist(a);
	J = find(a.nlab(:,curn) > 0); % Objects with nlab <= 0 have no labels
	if iscell(lablist)
		lablist = char(lablist);
	end
	if ischar(lablist)
		labels = char(zeros(m,size(lablist,2)));
		labels(J,:) = lablist(a.nlab(J,curn),:);
	else
		labels = repmat(NaN,m,1); %not recognized labels return NaN
		labels(J) = lablist(a.nlab(J,curn),:);
	end
case 'soft'
	labels = a.targets;
end
return
