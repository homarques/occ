%LINECOLOR Redefine linecolors
%
%   LINECOLOR(COLS,N)
%
% Redefines line colors in plot. COLS should contain 3 columns. Default is
% 2014 Matlab default. After N lines the color definition rotates.

function linecolor(cols,n)

if nargin < 1 || isempty(cols)
  cols = [
    0    0.4470    0.7410;
    0.8500    0.3250    0.0980;
    0.9290    0.6940    0.1250;
    0.4940    0.1840    0.5560;
    0.4660    0.6740    0.1880;
    0.3010    0.7450    0.9330;
    0.6350    0.0780    0.1840];
end
if size(cols,2) ~= 3
  error('Color definition should contain 3 columns')
end
if nargin < 2 || isempty(n)
  n = size(cols,1);
end
if n > size(cols,1)
  error(['Color definition should contain ' num2str(n) ' columns']);
end

h = get(gca,'children');
for i=1:numel(h)
  j = mod(i-1,n)+1;
  set(h(end-i+1),'color',cols(j,:));
end