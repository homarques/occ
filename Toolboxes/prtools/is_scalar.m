%IS_SCALAR Test on scalar (size = [1,1])
%
% 	N = IS_SCALAR(P);
%
% INPUT
%		P	 Input argument
%
% OUTPUT
%		N  1/0 if A is/isn't scalar
%
% DESCRIPTION
% The function IS_SCALAR tests if P is scalar.

function n = is_scalar(p)
			
	n = all(size(p) == ones(1,length(size(p))));
	if (nargout == 0) && (n == 0)
		error([prnewline 'Scalar variable expected.'])
	end
return;
