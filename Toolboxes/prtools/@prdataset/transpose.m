%TRANSPOSE Dataset overload 
%
% Returns the complex transpose of the data matrix.
% Construct a new dataset using the original feature labels as object
% labels and the other way around.

function a = transpose(a)

	nodatafile(a);
	data = a.data.';
  labels = getlabels(a);
  flabels = getfeatlab(a);
  a = prdataset(data,flabels);
  a = setfeatlab(a,labels);

return

