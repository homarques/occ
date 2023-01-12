%SHOW Display of objects in datasets, as images or functions
%
%       H = SHOW(A,N,BACKGROUND)
%
% Displays all objects stored in the dataset A. If the objects
% are images the standard Matlab imagesc-command is used for
% automatic scaling. If the features are images, they are 
% displayed. In case no images are stored in A all objects are
% plotted as functions using PLOTO.
% The number of horizontal figures is determined by N. If N is not
% given an approximately square window is generated.
% Borders between images and empty images are given the value 
% BACKGROUND (default: gray (0.5));
%
% Note that A should be defined by the dataset command, such that
% OBJSIZE or FEATSIZE contains the image size in order to detect 
% and reconstruct the images.
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% DATASETS, DATA2IM, IMAGE, PLOTO.

% Copyright: R.P.W. Duin
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% $Id: show.m,v 1.12 2009/07/15 11:27:19 duin Exp $

function [h,fullim] = show(a,nx,background)
		
if nargin < 3, background = 0.5; end
if nargin < 2, nx = []; end
clf;
cla;
[m,k] = size(a);

% if ~isdataim(a) || getfeatsize(a,1) == 1 || getfeatsize(a,2) == 1
if ~isdataim(a) || getfeatsize(a,1) == 1
	[hh ho hs] = ploto(a,nx); % might be very slow for 100 or more objects
	delete([ho hs]);
	if nargout > 0, h = hh; end
	return
end
if isfeatim(a) && (~isempty(getnlab(a))& getsize(a,3) > 0)
	a = [a getnlab(a)];
	%DXD: this can go horribly wrong when the features in 'a' have a
	%domain that is far outside (or inside) the domain of the numeric
	%labels [1...getsize(a,3)]. Therefore we rescale the features between
	%0 and 1:
	a = a*scalem(a,'domain');
end
im = data2im(a);
[y,x,z,nim] = size(im);

if isfeatim(a) && size(a,2) == z && nim == 1
	im = reshape(im,y,x,1,z);
	nim = z; z = 1;
end
if isobjim(a) 
	if size(a,1) == z && nim == 1
		im = reshape(im,y,x,1,z);
		nim = z; z = 1;
	elseif z~=1 && z~=3  % multiband object image
		im = reshape(im,y,x,1,z*nim);
		if isempty(nx)
			nx = ceil(sqrt(z*nim)/z)*z;
		end
		nim = z*nim; z = 1;
	end
	
end

if isempty(nx)
	for nx=1:m
		ny = ceil(nim/nx);
		if (ny*y) <= (nx*x), break; end
	end
else
	ny = ceil(nim/nx);
end
hh = []; 
n = ceil(max(x,y)*0.02);
x = x+n*2;
y = y+n*2;

for jy = 1:ny
	for jx =1:nx
		j = (jy-1)*nx + jx;
		if j>nim
			aim = background*ones(x,y,z); 
		else
			aim = im(:,:,:,j);
			mn = min(im(:));
			mx = max(im(:));
% 			mn = min(aim(:));
% 			mx = max(aim(:));
			aim = (aim-mn)/(mx-mn+eps); % avoid zero divide
			aim = bord(aim,background,n);
		end
		hh=[hh imagesc([1+(jx-1)*(x-n) jx*(x-n)+n],[1+(jy-1)*(y-n) jy*(y-n)+n],aim)];
		hold on
	end
end
hh = hh(1:nim);
axis([0 nx*(x-n)+n+1 0 ny*(y-n)+n+1]); 
%V=get(gcf,'position'); % use figure as defined ???
%V4 = [ny*y*V(3)/(nx*x)];
%V(2) = V(2) + V(4) - V4;
%V(4) = V4;
fullim = getimage(gca);
colormap('gray');
%set(gcf,'position',V);
set(gca,'position',[0 0 1 1]);
axis off;
%set(gcf,'menubar','none');
title(a.name);
if nargout > 0, h = hh; end
if nargout > 1, fullim = getimage(gca); end
hold off;
return

% C = bord(A,n,m)
% Puts a border of width m (default m=1) around image A
% and gives it value n. If n = NaN: mirror image values.
% $Id: show.m,v 1.12 2009/07/15 11:27:19 duin Exp $

function C = bord(A,n,m);
		if nargin == 2
  m=1;
   prwarning(4,'border width not supplied, assuming 1');
end
[x,y,z] = size(A);
if m > min(x,y)
	mm = min(x,y);
	C = bord(A,n,mm);
	C = bord(C,n,m-mm);
	return
end
if isnan(n)
   C = [A(:,m:-1:1,:),A,A(:,y:-1:y-m+1,:)];
   C = [C(m:-1:1,:,:);C;C(x:-1:x-m+1,:,:)];
else
   bx = ones(x,m,z)*n;
   by = ones(m,y+2*m,z)*n;
   C = [by;[bx,A,bx];by];
end
return

