%DD_MCC compute the MCC score 
%
%   E = DD_MCC(X,W)
%   E = DD_MCC(X*W)
%   E = X*W*DD_MCC
%
% INPUT
%   X    One-class dataset
%   W    One-class classifier
%
% OUTPUT
%   E    MCC performance
%
% DESCRIPTION
% Compute the MCC score of a dataset.
%
% SEE ALSO
% dd_error, dd_roc

%
% Copyright: H. O. Marques, hom@icmc.usp.br
% Data Pattern Analysis Lab. 
% ICMC-USP
%

function e = dd_mcc(x,w)

% Do it the same as testc:
% When no input arguments are given, we just return an empty mapping:
if nargin==0
	
   e = prmapping(mfilename,'fixed');
   e = setname(e,'MCC');
	return

elseif nargin == 1
	% Now we are doing the actual work, our input is a mapped dataset:

	% get the confusion matrix:
	c = dd_confmat(x);

	% and compute MCC:
	e = (c(1)*c(4)-c(3)*c(2))/sqrt((c(1)+c(3))*(c(1)+c(2))*(c(4)+c(3))*(c(4)+c(2)));

	if(isnan(e))
		e = 0;
	end

else

	ismapping(w);
	istrained(w);

	e = feval(mfilename,x*w);

end

return

