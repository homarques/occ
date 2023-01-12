%IMSIZE Retrieve size of a single image in a datafile or dataset
%
%	S = IMSIZE(A,N)
%
% Get size of image N (default N = 1) of datafile A.
% A might also be a dataset. All images in a dataset however have
% the same size.

function s = imsize(a,n)

if nargin < 2, n = 1; end
if isdataset(a)
	s = getfeatsize(a);
elseif isdatafile(a)
	s = getfeatsize(readdatafile(a(n,:),1,0));
else
	s = size(a);
end
	