%GETFEATDOM Get feature domain of a dataset
%
%	FEATDOM = GETFEATDOM(A,K)
%
% Returns the cell array with the feature domains of the features K of
% the dataset A.

% $Id: getfeatdom.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function featdom = getfeatdom(a,k)

	fd = a.featdom;
  if nargin > 1
    featdom = cell(1,length(k));
    for j = 1:length(k)
      n = k(j);
      if n > length(fd)
        featdom{j} = [];
      else
        featdom(j) = fd(n);
      end
    end
  else
    featdom = fd;
  end
    

return;
