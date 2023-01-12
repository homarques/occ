%Size Mapping overload
%
% The size of a mapping is [input_dimensionality,output_dimensionality]

% $Id: size.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function [s1,s2] = size(w,dim)
			s = [prod(w.size_in) prod(w.size_out)];
	if nargin == 2
		s = s(dim);
	end
	% take care for the output, sometimes two seperate scalars,
	% sometimes a vector with the sizes:
	if nargout < 2 
		s1 = s;
	else
		s1 = s(1); s2 = s(2);
	end
return
