%ISFIXED Test on fixed mapping
%
%    I = ISFIXED(W)
%    ISFIXED(W)
%
% True if the mapping type of W is 'fixed' (see HELP MAPPINGS). If called
% without an output argument ISFIXED generates an error if the mapping type
% of W is not 'fixed'.

% $Id: isfixed.m,v 1.3 2009/11/30 10:52:25 davidt Exp $

function i = isfixed(w)

		
	i = strcmp(w.mapping_type,'fixed') || strcmp(w.mapping_file,'fixedcc');

	if nargout == 0 && i == 0
		error([prnewline '---- Fixed mapping expected ----'])
	end

	return
