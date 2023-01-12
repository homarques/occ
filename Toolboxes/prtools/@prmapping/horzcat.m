%HORZCAT Mapping overload 
%
%	Horizontal concatenation of mappings is performed by STACKED.

% $Id: horzcat.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function w = horzcat(varargin)

	%disp('mappping-horzcat')
	if (nargin == 1) 
		% Matlab sometimes calls vertcat after horzcat without need
		w = varargin{1};
		return;
	else
		w = stacked(varargin{:});
	end
return;

