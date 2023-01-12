%GET Get dataset parameter fields 
%
%   [VALUE1,VALUE2,...] = GET(A,FIELD1,FIELD2,...)
%
% INPUT 
%   A       Dataset
%   FIELDx  Field names (strings)
%
% OUTPUT
%   VALUEx  Field values
%
% DESCRIPTION
% Get parameter fields (given as strings in FIELDx) of the dataset A:
%   DATA        datavectors
%   LABELS      labels of the datavectors
%   NLAB        numerical labels, index in lablist
%   FEATDOM     feature domains
%   FEATLAB     feature labels
%   PRIOR       prior probabilities
%   COST        classification cost matrix
%   LABLIST     labels of the classes
%   TARGETS     dataset with soft labels or targets
%   LABTYPE     label type: 'crisp','soft' or 'target'
%   OBJSIZE     number of objects or vector with its shape
%   FEATSIZE    number of features or vector with its shape
%   IDENT       identifier for objects
%   VERSION     version field
%   NAME        string with name of the dataset
%   USER        user field
% These names may be supplied in upper- or lowercase.
%
% EXAMPLES
% [DATA,NLAB] = GET(A,'data','nlab')
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% DATASETS, DATASET

% $Id: get.m,v 1.4 2006/12/19 12:12:13 duin Exp $

function varargout = get(a,varargin)

	if (isempty(varargin)), return, end

	if (nargout > 0) && (length(varargin) ~= nargout)
		error('Wrong number of output parameters')
	end

	% Print or return all requested fields.

  for j = 1:length(varargin)

  	name = varargin{j};

  	switch (name)
    	case {'DATA','data'}
    		v = a.data;
    	case {'LABELS','labels'}
				curn = curlablist(a);
				lablista = getlablist(a);
    		v = lablista(a.nlab(:,curn),:);
    	case {'NLAB','nlab'}
    		v = a.nlab;
    	case {'FEATLAB','featlab'}
    		v = a.featlab;
    	case {'FEATDOM','featdom'}
    		v = a.featdom;
    	case {'LABLIST','lablist'}
    		v = a.lablist;
    	case {'PRIOR','prior'}
    		v = a.prior;
    	case {'COST','cost'}
    		v = a.cost;
    	case {'TARGETS','targets'}
    		v = a.targets;
    	case {'LABTYPE','labtype'}
    		v = a.labtype;
    	case {'OBJSIZE','objsize'}
    		v = a.objsize;
    	case {'FEATSIZE','featsize'}
    		v = a.featsize;
    	case {'IDENT','ident'}
    		v = a.ident;
    	case {'NAME','name'}
    		v = a.name;
    	case {'VERSION','version'}
    		v = a.version;
    	case {'USER','user'}
    		v = a.user;
    	otherwise
    		error(['Unknown dataset field found: ' name])
  	end

		% If no output argument is specified, display the value.

  	if (nargout == 0)
  		disp(' ')
  		disp(v)
  		if (isempty(v))
  			disp('[]')
  		end
  	else
  		varargout{j} = v;
  	end

  end

return
