%CTRANSPOSE Dataset overload 
%
% Returns the complex conjugate transpose of the data matrix.
% Construct a new dataset using the original feature labels as object
% labels and the other way around.

% $Id: ctranspose.m,v 1.3 2007/03/22 07:45:54 duin Exp $

function a = ctranspose(a)

	nodatafile(a);
	data = a.data';
  labels = getlabels(a);
  flabels = getfeatlab(a);
  a = prdataset(data,flabels);
  a = setfeatlab(a,labels);

return

