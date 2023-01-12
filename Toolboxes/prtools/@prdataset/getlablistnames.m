%GETLABLISTNAMES Get the names of all label lists
%
%	NAMES = GETLABLISTNAMES(A)
%
% INPUT
%   A      - Dataset
%
% OUTPUT
%   NAMES  - Character array with label list names
%
% DESCRIPTION
% All label list names are returned in NAMES. In case no multiple
% labeling is set, NAMES = 'default'.
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% DATASETS, MULTI_LABELING, ADDLABELS, ADDLABLIST, CHANGELABLIST,
% CURLABLIST, SETLABLISTNAMES

% Copyright: R.P.W. Duin
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function out = getlablistnames(a)
				
	if ~iscell(a.lablist)
		names = 'default';
	else
		names = a.lablist{end,1};
  end
  if nargout == 0
    [n,k] = size(names);
    kk = max(k-8,1);
    fprintf('\n   # lablist %s #classes   classsizes\n',repmat(' ',1,kk))
    fprintf('   ------------------------------------------\n')
    for j=1:n
      a = changelablist(a,j);
      c = getsize(a,3);
      s = classsizes(a);
      cc = min(c,10);
      fprintf('  %2d %s   %3d    %s',j,names(j,:),c,sprintf('%5d',s(1:cc)));
      if c > cc
        fprintf(' .....');
      end
      fprintf('\n')
    end
    fprintf('\n')
  else
    out = names;
  end
	
return
