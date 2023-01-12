%SETMAPPING_TYPE Set mapping type
%
%    W = SETMAPPING_TYPE(W,MAPPING_TYPE)

% $Id: setmapping_type.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function w = setmapping_type(w,mapping_type)

	if isempty(mapping_type)
		w.mapping_type = 'untrained';
	else
		if strcmp(mapping_type,'untrained') || ...
			    strcmp(mapping_type,'trained') || ...
			    strcmp(mapping_type,'fixed') || ...
			    strcmp(mapping_type,'fixed_cell') || ...
			    strcmp(mapping_type,'generator') || ...
			    strcmp(mapping_type,'combiner')
			
			w.mapping_type = mapping_type;
		else
			error('Unknown mapping type')
		end
	end

	return
