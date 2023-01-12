%SET Set dataset fields 
%
%    A = SET(A,VARARGIN)
%
% Sets dataset fields (given as strings in VARARGIN) of the dataset A.
% E.G.: A = SET(A,'data',DATA,'nlab',NLAB).
% This is not different from using the field specific routines
% (e.g. SETDATA(A,DATA)
%
% List of parameter fields:
%
% DATA        datavectors
% LABELS      labels of the datavectors
% NLAB        nummeric labels, index in lablist
% FEATDOM     feature domains
% FEATLAB     feature labels
% PRIOR       prior probabilities
% COST        classification cost matrix
% LABLIST     labels of the classes
% TARGETS     dataset with soft labels or targets
% LABTYPE     label type: 'crisp','soft' or 'target'
% OBJSIZE     number of objects or vector with its shape
% FEATSIZE    number of features or vector with its shape
% IDENT       identifier for objects
% VERSION     version field
% NAME        string with name of the dataset
% USER        user field
%
% See datasets, dataset for more information

% $Id: set.m,v 1.6 2008/09/29 08:30:50 duin Exp $

function a = set(a,varargin)

	if isempty(varargin), return, end

	[m,k,c] = getsize(a);
	for j=1:2:nargin-1
		
		name = varargin{j};
		
		if j == nargin+1
			error('No data found for field')
		else
			v = varargin{j+1};
		end

		switch name

		 case {'DATA','data'}
			 a = setdata(a,v);
     case {'LABELS','labels'}
       a = setlabels(a,v);
		 case {'NLAB','nlab'}
       a = setnlab(a,v);
		 case {'TARGETS','targets'}
       a = settargets(a,v);
		 case {'LABLIST','lablist'}
       a = setlablist(a,v);
		 case {'FEATLAB','featlab'}
       a = setfeatlab(a,v);
		 case {'FEATDOM','featdom'}
       a = setfeatdom(a,v);
		 case {'PRIOR','prior'}
       a = setprior(a,v);
		 case {'COST','cost'}
       a = setcost(a,v);
		 case {'LABTYPE','labtype'}
       a = setlabtype(a,v);
		 case {'OBJSIZE','objsize'}
       a = setobjsize(a,v);
		 case {'FEATSIZE','featsize'}
       a = setfeatsize(a,v);
		 case {'IDENT','ident'}
       a = setident(a,v);
		 case {'VERSION','version'}
       a = setversion(a,v);
		 case {'NAME','name'}
       a = setname(a,v);
		 case {'USER','user'}
       a = setuser(a,v);
		 otherwise
		  error(['Unknown dataset field: ' name])
		end
	end

	return
