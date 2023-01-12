%CORRCOEF Dataset overload
%
%   D = CORRCOEF(A)
%
% D is a dataset with the correlations between all features in A. The object
% labels as well as the feature labels of D are equal to the feature labels
% of A.
%
%   D = CORRCOEF(A,B)
%
% D is a dataset with the correlations between the 1D datasets A and B.

% $Id: corrcoef.m,v 1.3 2007/03/22 07:45:54 duin Exp $

function d = corrcoef(a,b)
		

  if (nargin == 1)

		% Apply CORRCOEF to the data in A and create an output dataset D.
		a = datasetconv(a);
  	d = prdataset(corrcoef(a.data),a.featlab);
  	d.featlab = a.featlab;

  else 																	

		% Make sure we have 2 1D datasets and that they are of equal size.
		a = datasetconv(a);
		b = datasetconv(b);
  	if (size(a,2) ~= 1) || (size(b,2) ~= 1)
  		error('1-dimensional datasets expected')
  	end
  	if (size(a,1) ~= size(b,1))
  		error('Datasets A and B should have an equal number of objects.')
  	end

		% Apply this function to the concatenation of A and B.
  	d = corrcoef([a b]);

  end

return
