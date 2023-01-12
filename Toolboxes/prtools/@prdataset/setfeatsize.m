%SETFEATSIZE Set the feature size of a dataset
%
%   A = SETFEATSIZE(A,FEATSIZE)
%
% INPUT 
%   A         Dataset
%   FEATSIZE  Feature size vector
% 
% OUTPUT
%   A         Dataset
%
% DESCRIPTION
% By default the feature size of a dataset is its number of features, i.e.
% the number of columns in the DATA field of A. If the features are samples
% of a multi-dimensional data item, e.g. the pixels of an image, the
% original size of this data item may be stored in FEATSIZE. The product of
% all elements in FEATSIZE has to be equal to the number of columns in the
% DATA field of A.

% $Id: setfeatsize.m,v 1.6 2009/03/10 10:46:50 duin Exp $

function a = setfeatsize(a,featsize)

	[m,k] = size(a.data);
  
  if nargin < 2 || isempty(featsize)
    featsize = k;
  end

	% Check whether FEATSIZE is a vector such that the sizes multiply to
	% the number of features in A.

	if (min(size(featsize)) ~= 1)
		error('Feature size should be a vector.')
	end
	if (k ~= 0) && (prod(featsize) ~= k)
		error([prnewline, ...
		'The total feature size does not fit with the real number of features.', ...
		prnewline, 'This might be caused when mappings are applied to datafiles with objects of different size.', ...
		prnewline])
	end

	% let images always have a single band
	%if length(featsize) == 2, featsize = [featsize 1]; end % really needed?
	%solved in getfeatsize?
	
	a.featsize = featsize;

return
