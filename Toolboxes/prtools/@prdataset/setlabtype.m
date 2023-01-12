%SETLABTYPE Reset label type of dataset
%
%    A = SETLABTYPE(A,TYPE,LABELS)
%
% The label type of the dataset A is converted to TYPE ('crisp','soft' or
% 'targets'). A conversion of the dataset fields 'nlab', 'lablist' and
% 'targets' is made where necessary. If given, LABELS replaces the labels
% or targets of A.
%
% EXAMPLE
% a = prdataset(rand(10,5)); % create dataset of 10 objects and 5 features
% a = setlabtype(a,'soft',rand(10,1)); % give it random soft labels

% $Id: setlabtype.m,v 1.8 2009/09/28 08:37:40 duin Exp $

function a = setlabtype(a,type,labels)
		[m,k,c] = getsize(a);

a = addlablist(a);   % set up multiple labels if not yet done
[curn,curname,t0,t1] = curlablist(a);
if nargin == 3                % no coversion, just creation
	switch type
	case {'crisp','CRISP'}      % create crisp
			a.labtype = 'crisp';
	case {'soft','SOFT'}        % create soft
			a.labtype = 'soft';
	case {'targets','TARGETS'}   % create soft
			a.labtype = 'targets';
	otherwise
			error(['Unknown label type: ',type])
  end
  a.lablist{curlablist(a),4} = a.labtype;
	a = setlabels(a,labels);
	return
end

switch type
case {'crisp','CRISP'}     % convert to crisp
	switch a.labtype
	case {'soft','targets'}  % from soft or targets
    [mm,nlaba] = max(a.targets(:,t0:t1),[],2); % reset nlab 
		a.nlab(:,curn) = nlaba-t0+1;
    a.targets(:,t0:t1) = [];                    % and targets
		a.lablist{end,3}(curn) = 0;
	end
case {'soft','SOFT'}       % convert to soft
% 	if c < 1
% 		error('Soft labeled datasets should contain at least one class')
% 	end
	switch a.labtype
	case 'crisp'             % from crisp
		prior = getprior(a,0);
		a.labtype = 'soft';
		a = settargets(a,zeros(m,c));% make target field ready (will be 0-1)
		for j=1:c
			J = find(a.nlab(:,curn) == j);
			a.targets(J,t0+j-1) = ones(length(J),1); % ones it for the right class
		end
		a = setprior(a,prior); % priors are lost during conversion: correct!
	case 'targets'           % from targets
		[mm,nlaba] = max(a.targets(:,t0:t1),[],2);
		nlaba = nlaba-t0+1;
		a.nlab(:,curn) = nlaba;
		if any(a.targets(:,t0:t1) < 0) || any(a.targets(:,t0:t1) > 1) % convert if ouside 0-1
			a.targets(:,t0:t1) = sigm(a.targets(:,t0:t1));
			prwarning(10,'targets converted to soft labels by sigm')
		end
	end
case {'targets','TARGETS'}        % convert to targets
	switch a.labtype
  case 'crisp'                    % from crisp, in two steps
		if c >= 1
			a = setlabtype(a,'soft');   % first to soft labels (0-1)
			a = setlabtype(a,'targets');% then to targets, see below
		end
	case 'soft'                     % from soft
		a.targets(:,t0:t1) = 2*a.targets(:,t0:t1) - 1;  % convert 0,1 interval to -1,1 interval
		a.nlab(:,curn) = zeros(m,1);  % reset nlab
    a.prior = [];                 % no class priors
    a.cost  = [];                 % np classification costs
	end
otherwise
	error(['Unknown label type: ',type])
end
a.lablist{curn,4} = lower(type);
a.labtype = lower(type);

%if nargin > 2
%	a = setlabels(a,labels);
%end
%return
