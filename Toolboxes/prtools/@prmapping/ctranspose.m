%CTRANSPOSE Transpose mapping (sequential or affine)
%
%	  W = CTRANSPOSE(W)
%	  W = W'
%
% INPUT
%   W  Mapping
%
% OUTPUT
%   W  Transposed mapping
%
% DESCRIPTION
% For the case of affine (linear) mappings (or sequential combinations of
% these), the transpose mapping is defined and returned. For other mappings 
% an error will be generated. See AFFINE.

% $Id: ctranspose.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function w = ctranspose(w)

	if (isclassifier(w))
		warning('Transpose for classifiers under construction.')
		if w.size_out > 2
			error('Transpose not defined for multiclass classifiers')
		end
		w.out_conv = 0;
		w.size_out = 1;
		w.labels = 1;
		w.data.rot(:,2) = [];
		w.data.offset(2) = [];
		struct(w)
		w.data
	end

	if (strcmp(w.mapping_file,'sequential'))
		w = w.d{2}'*w.d{1}';												% Call recursively.
	elseif (isaffine(w))
		w.labels = [];															% Remove labels.
		c = w.size_out; k = w.size_in;							% Switch dimensions.
		w.size_out = k; w.size_in = c;
		k = prod(k);																% Apply transpose.
		v = sum(w.data.rot.*w.data.rot);
		w.data.rot = (w.data.rot./repmat(v,k,1))';
		w.data.offset = -w.data.offset*w.data.rot;
		w.scale = 1;
	else
		error(['Transpose not defined for mapping type ' w.m '.']);
	end

return
