%SETOBJSIZE Reset the object size of a dataset
%
%    A = SETOBJSIZE(A,OBJSIZE)
%
% By default, the object size of a dataset A is given by the number of objects, 
% i.e. the number of rows in the DATA field of A. If the objects are samples of
% a multi-dimensional data item, e.g. the pixels of an image, the original size
% of this data item may be stored in OBJSIZE. The product of all elements in 
% OBJSIZE has to be equal to the number of rows in the DATA field of A.

% $Id: setobjsize.m,v 1.3 2007/01/16 16:10:12 duin Exp $

function a = setobjsize(a,objsize)

	[m,k] = size(a.data);
	if (min(size(objsize)) ~= 1)
		error('Object size should be a vector')
	end

	if (m > 0 && prod(objsize) ~= m)
		error('The supplied object size does not fit with the number of objects')
	end
	a.objsize = objsize;

return;
