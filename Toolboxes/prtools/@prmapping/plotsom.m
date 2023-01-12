%PLOTSOM Plot the Self-Organizing Map in 2D
%
%    PLOTSOM(W)
%
% Plot the Self-Organizing Map W, trained by som.m. This is only
% possible if the map is 2D.
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% SOM

function h = plotsom(W)

persistent plotsom_warning
if isempty(plotsom_warning)
  warning('Use of ''plotsom'' for SOM mappings is deprecated. Use ''prplotsom'' instead');
  plotsom_warning = 1;
end

hh = prplotsom(W);
if nargout > 0
  h = hh;
end
  
return