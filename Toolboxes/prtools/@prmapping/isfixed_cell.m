%ISFIXED_CELL Test on fixed_cell mapping
%
%    I = ISFIXED_CELL(W)
%    ISFIXED_CELL(W)
%
% True if the mapping type of W is 'fixed_cell' (see HELP MAPPINGS).  
% If called without an output argument ISFIXED_CELL generates an error if 
% the mapping type of W is not 'fixed_cell'.

% $Id: isfixed.m,v 1.3 2009/11/30 10:52:25 davidt Exp $

function i = isfixed_cell(w)

		
	i = strcmp(w.mapping_type,'fixed_cell');

	if nargout == 0 && i == 0
		error([prnewline '---- fixed_cell mapping expected ----'])
	end

	return
