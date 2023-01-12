%SETTARGETS Reset targets or soft labels of dataset
%
%     A = SETTARGETS(A,TARGETS,LABLIST)
%
% The targets or soft label values of the dataset A are reset to TARGETS. 
% This has to be an array or a dataset of size [M,C], in which M is
% the number of objects in A and C is the number of targets or classes.
% The names of these targets or classes can be supplied in the column
% vector LABLIST (numbers, characters or strings) of length C.
% Alternatively, TARGETS may be a dataset with feature labels
% (FEATLAB) equal to LABLIST.

% $Id: settargets.m,v 1.6 2007/10/26 09:57:09 davidt Exp $

function a = settargets(a,targets,lablist)
			
	nodatafile(a);
    
  if nargin < 3
    lablist =[];
  end
  
  if strcmp(a.labtype,'crisp')
	  error('Targets are not defined for datasets with label type ''crisp''')
  end

  if isdataset(targets)
    if isempty(lablist) || size(lablist,1)~=size(targets.featlab,1)
      lablist = targets.featlab;
    end
    targets = targets.data;
  end
      
  a = newtargets(a,targets);
  
  if ~isempty(lablist)
	  a = setlablist(a,lablist);
  end
  
return

function a = newtargets(a,targets)

  % position new targets in a.targets and update admin
	% t0 is desired start column in a.targets
	% t1 is desired end column in a.targets
  
	curn = curlablist(a);
	acttargetsize = cumsum([0 a.lablist{end,3}]);
	t0 = acttargetsize(curn)+1;
	t1 = acttargetsize(curn+1);
	newtargetsize = size(targets,2);
		
	if a.lablist{end,3}(curn) ~= newtargetsize
		if t0 == 1
			before = []; 
		else 
			before = a.targets(:,1:t0-1); 
		end
		if t1 == size(a.targets,2)
			after = []; 
		else 
			after = a.targets(:,1:t0-1); 
		end
		a.targets = [before zeros(size(targets,1),newtargetsize) after];
		a.lablist{end,3}(curn) = newtargetsize;
    t1 = t0+newtargetsize-1;
	end
	a.targets(:,t0:t1) = targets;
    
return
