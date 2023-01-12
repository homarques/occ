%INPOLY Select dataset objects inside / outside a polygon in a scatter plot
%
%  [JIN,JOUT] = INPOLY(A,H)
%
% INPUT
%   A     2D dataset
%   H     handle returned by IMPOLY
%
% OUTPUT
%   JIN   Object indices of A inside polygon
%   JOUT  Object indices of A outside polygon
%
% DESCRIPTION
% The purpose of this routine is to find the objects inside / outside
% a polygon created by IMPOLY on a scatterplot, e.g. created by SCATTERD.
%
% EXAMPLE
% delfigs
% a = gendatb;
% scatterd(a)
% disp('Draw a polygon in the scatterplot')
% h = impoly;  % use the mouse to draw a polygon in the scatterplot
% [jin,jout] = inpoly(a,h);
% hold on; scatterd(a(jin,:),'ko'); % encircle selected objects
% figure;  scatterd(a(jout,:));     % show objects outside polygon
% showfigs
%
% SEE ALSO
% SCATTERD, IMPOLY

function [jin,jout] = inpoly(a,h)

if ~isa(h,'impoly')
  error('Handle is not of class impoly')
end
y = getPosition(h);
jin = find(inpolygon(+a(:,1),+a(:,2),y(:,1),y(:,2)));
if nargout > 1
  jout = 1:size(a,1);
  jout(jin) = [];
end