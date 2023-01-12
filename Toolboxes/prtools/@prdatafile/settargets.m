%SETTARGETS Reset targets or soft labels of datafile
%
%     A = SETTARGETS(A,TARGETS)
%
% TARGETS should be a datafile with feature labels
% (FEATLAB) used for the desired LABLIST.

% $Id: settargets.m,v 1.4 2007/10/25 19:53:38 duin Exp $

function a = settargets(a,targets)
			
	%if ~isdatafile(targets) && ~isdataset(targets)
	%	error('Targets should be supplied in datafile')
	%end
	
	a = dyadic(a,'settargets',targets,size(a,2));
	
return