%HIST Display feature histograms
%
%     HANDLE = HIST(A,P,NX)
%     HANDLE = HIST(+A)
%
% INPUT
%  A       Dataset
%  P       # of bins
%  NX      # of histograms displayed in a row
%
% OUTPUT
%  HANDLE  handle of subplot
% 
% DESCRIPTION
% For all feature (columns) of A a histogram is plot using P bins.
% These histograms are plot as subplots in a single figure, displaying
% NX histograms in a row. In HANDLE the handles of the subplots are 
% returned.
%
% Note that this routine is not a true overload of the HIST command.
% Use HIST(+A) if that is desired.

% $Id: hist.m,v 1.3 2007/03/22 07:45:54 duin Exp $

function h_out = hist(a,p,nx)
		
nodatafile(a);

if nargin < 3
  nx = [];
  prwarning(4,'# of  histograms displayed in a row not supplied, optimizing');

end

if nargin < 2
  p = 25;
  prwarning(4,'# of bins not supplied, assuming 25');
end

[m,k] = size(a);
if isempty(nx), nx = ceil(sqrt(k)); end
  ny = ceil(k/nx);
  clf;
  cla;
  a = +a;
  h = [];
  for j=1:ny
    for i=1:nx, % plot nx subplots in a row
	   n = (j-1)*nx + i;
	   if n > k, break; end
	    h = [h subplot(ny,nx,n)];
	    hist(a(:,n),p);
    end
  end

if nargout > 0
	h_out = h;
end
return
