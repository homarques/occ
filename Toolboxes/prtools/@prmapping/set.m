%SET Set mapping parameters
%
%	    W = SET(W,NAME1,VALUE1,NAME1,VALUE1,...)
%
% Sets the fields given by their names (as strings) of the mapping W to the
% supplied values.E.G.: W = SET(W,'data',{DATA1,DATA2},'labels',LABELS).
% This is not different from using the field specific routines
% (e.g. SETDATA(W,{DATA1,DATA2})
%
% List of field names, see also MAPPING:
%
% MAPPING_FILE  name of the routine used for learning or executing the mapping
% MAPPING_TYPE  string defining the type of mapping:
%               'untrained', 'trained', "combiner' or 'fixed'.
% DATA          Data, structure or cell array needed for defining the mapping.
% LABELS        Array with labels to be used as feature labels for the dataset
%               created by executing the mapping.
% SIZE_IN       Input dimensionality or size vector describing its shape.
% SIZE_OUT      Output dimensionality or size vector describing its shape.
% SIZE          Not a field, but sets both, SIZE_IN and SIZE_OUT from a vector.
% SCALE         Output multiplication factor or vector.
% OUT_CONV      0,1,2,3 for defining the desired output conversion:
%               0 - no (default), 1 - SIGM, 2 NORMM or 3 - SIGM and NORMM.
% COST          classification cost matrix.
% NAME          String with mapping name.
% USER          User definable variable.
%
% See also DATASETS, MAPPINGS, MAPPING

% $Id: set.m,v 1.3 2007/03/12 20:21:31 duin Exp $

function w = set(w,varargin)
		
	if isempty(varargin), return, end

	for j=1:2:nargin-1

		name = varargin{j};

		if j == (nargin-1)
			error('No data found for field')
		else
			v = varargin{j+1};
		end

		switch name
		case {'MAPPING_FILE','mapping_file'}
			w = setmapping_file(w,v);
		case {'MAPPING_TYPE','mapping_type'}
			w = setmapping_type(w,v);
		case {'DATA','data'}
			w = setdata(w,v);
		case {'LABELS','labels'}
			w = setlabels(w,v);
		case {'SIZE_IN','size_in'}
			w = setsize_in(w,v);
		case {'SIZE_OUT','size_out'}
			w = setsize_out(w,v);
		case {'SIZE','size'}
			w = setsize(w,v);
		case {'SCALE','scale'}
			w = setscale(w,v);
		case {'OUT_CONV','out_conv'}
			w = setout_conv(w,v);
		case {'COST','cost'}
			w = setcost(w,v);
		case {'NAME','name'}
			w = setname(w,v);
		case {'USER','user'}
			w = setuser(w,v);
		otherwise
			error(['Unknown field name found ' name])
		end
	end
return
