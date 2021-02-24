%SHOWFIGS Show all figures on the screen
%
%  SHOWFIGS(K,DH,DV)
%
% Use K figures on a row. Shift image positions by DX and DY.

function showfigs(k,dx,dy)

h = sort(double(get(0,'children')));  % handles for all figures
n = length(h);                % number of figure
if nargin == 0
	k = ceil(sqrt(n));          % figures to be shown
end
if nargin < 3
  dx = 0;
  dy = 0;
end
s = 0.93/k;   % screen stitch
r = 0.93;     % image size reduction
t = 0.055+dy;    % top gap
b = 0.005+dx;    % border gap
fig = 0;
set(0,'units','pixels');
if isoctave
  rootprop = get(0);
  monpos = getfield(rootprop,'monitorpositions');
else
  monpos = get(0,'monitorposition');
end
monpos = monpos(1,:);
minsize = min(monpos(3:4));
for i=1:k
	for j=1:k
		fig = fig+1;
		if fig > n, break; end
		set(h(fig),'units','pixels','position',[(j-1)*s+b,(1-t)-i*s+0.02,s*r,s*r]*minsize);
		%figure(h(fig));
	end
end
for j=n:-1:1, figure(h(j)); end