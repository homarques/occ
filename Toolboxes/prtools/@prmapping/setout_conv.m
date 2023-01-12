%SETOUT_CONV Set output conversion field for mapping
%
%  W = SETOUT_CONV(W,OUT_CONV)
%
% INPUT
%   W         Mapping
%   OUT_CONV  Output conversion field: 0, 1, 2 or 3 (see MAPPING)
%
% OUTPUT
%   W         Mapping

% $Id: setout_conv.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function w = setout_conv(w,out_conv)

	if (max(size(out_conv)) > 1) || ...
		 (out_conv < 0) || (out_conv > 3) || (round(out_conv) ~= out_conv)
		error('Mapping output conversion should be given as integer (0, 1, 2 or 3).')
	end

	w.out_conv = out_conv;

return
