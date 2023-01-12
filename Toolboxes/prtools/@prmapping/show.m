%SHOW Display axes of affine mappings as images, if available
%
%    SHOW(W,N,BACKGROUND)
%
% If W is a affine mapping operating in a space defined by images
% (i.e. each object in the space is an image) and the image size is
% properly stored in W (SIZE_IN), then the images corresponding to the axes
% of the affine mapping are displayed.
%
% The number of horizontal images is determined by N. If N is not given an
% approximately square window is generated.
%
% Borders between images and empty images are given the value 
% BACKGROUND (default: gray (0.5));

% Copyright: R.P.W. Duin
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% $Id: show.m,v 1.4 2009/02/02 21:44:09 duin Exp $

function show(w,n,background)

		
	if ~strcmp(w.mapping_file,'affine')
		error('Display for given mapping not possible')
	end
	if length(w.size_in) == 2
		error('No proper image size found')
	end
	[k,c] = size(w);
	a = prdataset(w.data.rot',w.labels(1:c,:));
	a = setfeatsize(a,w.size_in);
	%if c == 2
	%	a = a(1,:);
	%end
	if nargin < 3, background = 0.5; end
	if nargin < 2, n = []; end
	show(a,n,background);

return
