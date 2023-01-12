%UPLUS Fast extraction of the mapping data
%
%	  D = +W
%
% Converts a mapping object W to an object D, which is the
% contents of the mapping data field.

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: uplus.m,v 1.3 2009/07/26 19:12:36 duin Exp $

function d = uplus(w)

	d = w.data;
  if iscell(d) && length(d) == 1
    d = d{1};
  end

return;
