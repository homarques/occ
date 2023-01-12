%PRDATASET Conversion of affine mapping to dataset
%
%	A = PRDATASET(W)
%
% If W is a m x k affine mapping, the axes of the map
% are returned as a m x k dataset A.

% $Id: dataset.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function a = prdataset(w)

		
	if ~strcmp(w.mapping_file,'affine')
		error('Dataset conversion only defined for affine mappings')
	end
	a = prdataset(w.data{1},[],w.labels);
	a = set(a,'objsize',w.size_in,'featsize',w.size_out);
	
	return
