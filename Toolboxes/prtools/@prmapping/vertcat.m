%VERTCAT Mapping overload 
%
%  Vertical concatenation of mappings is performed by PARALLEL

% $Id: vertcat.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function w = vertcat(varargin)

		
	%disp('mappping-vertcat')
	if nargin == 1
		% Matlab sometimes calls vertcat after horzcat without need
		w = varargin{1};
		return
	else
		w = parallel(varargin{:});
	end

	return
