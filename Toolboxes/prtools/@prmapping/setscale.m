%SETSCALE Set scale field (output scaling) in mapping
%
%    W = SETSCALE(W,SCALE)
%
% This sets the SCALE field in W. If W is affine, scaling is is directly
% performed in the weights in W.DATA and W.SCALE = 1.

% $Id: setscale.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function w = setscale(w,scale)
		if min(size(scale)) > 1
	error('Mapping scale should be given as scalar or row vector')
end
if length(scale) > 1 && length(scale) ~= size(w,2)
	error('Mismatch between size of scale vector and output dimensionality')
end
if strcmp(w.mapping_file,'affine')
	if max(size(scale)) == 1
		w.data.rot = w.data.rot*scale;
		w.data.offset = w.data.offset*scale;
	else
		w.data.rot = w.data.rot.*repmat(scale(:)',size(w,1),1);
		w.data.offset = w.data.offset.*scale(:)';
	end
	scale = 1;
end
w.scale = scale;
return
