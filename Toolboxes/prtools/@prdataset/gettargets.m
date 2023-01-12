%GETTARGETS Get targets of dataset
%
%    [TARGETS,LABLIST] = GETTARGETS(A)
%
% Gets the targets (or soft labels) of the objects in the dataset A.  If A
% has crisp labels they are converted to targets first. See SETLABTYPE for
% conversion rules.
%
%    [TARGETS,LABLIST] = GETTARGETS(A,'soft')
%
% Forces the return of soft labels. This command is identical to
% GETLABELS(A,'soft'). If A has crisp labels or target labels they are
% converted to soft labels first. See SETLABTYPE for conversion rules.
%
% See also SETLABTYPE, GETLABELS, SETLABELS, SETTARGETS

% $Id: gettargets.m,v 1.5 2007/03/22 07:45:54 duin Exp $

function [targets,lablist] = gettargets(a,type)

		
	lablist = a.lablist;
	if nargin > 1
		a = setlabtype(a,type);
	end

	if strcmp(a.labtype,'crisp')
		a = setlabtype(a,'targets');
	end

	curn = curlablist(a);
	acttargetsize = cumsum([0 a.lablist{end,3}]);
	t0 = acttargetsize(curn)+1;
	t1 = acttargetsize(curn+1);
	targets = a.targets(:,t0:t1);

	return
