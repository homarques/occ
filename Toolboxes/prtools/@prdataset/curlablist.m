%CURLABLIST Get current label list 
%
% [LABLISTNUMBER,LABLISTNAME,T0,T1] = CURLABLIST(A)
%
% INPUT
%   A             - Dataset
%
% OUTPUT
%   LABLISTNUMBER - Number of current lablist
%   LABLISTNAME   - Name of current label list
%		T0            - Start column current targets
%   T1            - End column current targets
%
% DESCRIPTION
% The number and name of the current label list are returned.
% If T1<T0: no targets (or soft labels) set for current label list.
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% DATASETS, MULTI_LABELING, ADDLABLIST, CHANGELABLIST

% Copyright: R.P.W. Duin
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function [n,name,t0,t1] = curlablist(a)
				
	if ~iscell(a.lablist) % no multiple labels defined
		n = 1;
		name = 'default';
	else
		n = a.lablist{end,2};
		lablist = a.lablist{end,1};
		name = deblank(lablist(n,:));
	end
	
	if nargout > 2
		targetsize = cumsum([0 a.lablist{end,3}]);
		t0 = targetsize(n)+1;
		t1 = targetsize(n+1);
	end
		