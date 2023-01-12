%GET Get mapping parameter fields
%
%   [VALUE1,VALUE2,...] = GET(W,FIELD1,FIELD2,...)
%
% INPUT
%   W       Mapping
%   FIELDx  Field names (strings)
% 
% OUTPUT
%   VALUEx  Value of field x
%
% DESCRIPTION
% Get the values of the fields in W specified by FIELD1 etc. Note that mapping
% fields may also be extracted directly by, e.g. W.DATA.
%
% List of field names (see also MAPPING):
%
%   MAPPING_FILE  name of the routine used for learning or executing the mapping
%   MAPPING_TYPE  string defining the type of mapping:
%                 'untrained', 'trained', "combiner' or 'fixed'.
%   DATA          data, structure or cell array needed for defining the mapping.
%   LABELS        array with labels to be used as feature labels for the dataset
%                 created by executing the mapping.
%   SIZE_IN       input dimensionality or size vector describing its shape.
%   SIZE_OUT      output dimensionality or size vector describing its shape.
%   SCALE         output multiplication factor or vector.
%   OUT_CONV      0,1,2,3 for defining the desired output conversion:
%                 0 - no (default), 1 - SIGM, 2 NORMM or 3 - SIGM and NORMM.
%   COST          classification cost matrix
%   NAME          string with mapping name.
%   USER          user definable variable.
%   VERSION       version field
%
% EXAMPLES
% [DATA,LABELS] = GET(W,'data','labels')
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% DATASETS, MAPPINGS, MAPPING

% $Id: get.m,v 1.3 2006/12/19 12:13:19 duin Exp $

function varargout = get(w,varargin)

	if (isempty(varargin)), return; end

	if (nargout > 0) && (length(varargin) ~= nargout)
		error('Wrong number of output parameters.')
	end

	% Add the values of the fields specified in VARARGIN to the output.

	for j = 1:length(varargin)

  	name = varargin{j};
  	
  	switch (name)
    	case {'MAPPING_FILE','mapping_file'}
    		v = w.mapping_file;
    	case {'MAPPING_TYPE','mapping_type'}
    		v = w.mapping_type;
    	case {'DATA','data'}
    		v = w.data;
    	case {'LABELS','labels'}
    		v = w.labels;
    	case {'SIZE_IN','size_in'}
    		v = w.size_in;
    	case {'SIZE_OUT','size_out'}
    		v = w.size_out;
    	case {'SIZE','size'}
    		v = size(w);
    	case {'SCALE','scale'}
    		v = w.scale;
    	case {'OUT_CONV','out_conv'}
    		v = w.out_conv;
			case {'COST','cost'}
				v = w.cost;
    	case {'NAME','name'}
    		v = w.name;
    	case {'USER','user'}
    		v = w.user;
    	case {'VERSION','version'}
    		v = w.version;
    	otherwise
    		error('Unknown mapping field found')
  	end

		% If no output arguments are requested, display the values. Otherwise,
    % return them.

  	if (nargout == 0)
  		disp(' ');
  		disp(v);
  		disp(' ');
  	else
  		varargout{j} = v;
  	end

  end

return
	
