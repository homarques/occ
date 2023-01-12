%DOUBLE Dataset to double conversion
%
%	D = double(A)
%
% Converts a dataset A to a double D, which is just the set of datavectors.

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: double.m,v 1.3 2007/03/22 07:45:54 duin Exp $

function d = double(a)

				
	a = datasetconv(a);
  d = a.data;
	
return
