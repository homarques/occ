%DD_PREC compute the prec-at-n score 
%
%   [PREC, ADJ] = DD_PREC(X,W)
%   [PREC, ADJ] = DD_PREC(X*W)
%   [PREC, ADJ] = X*W*DD_PREC
%
% INPUT
%   X    One-class dataset
%   W    One-class classifier
%
% OUTPUT
%   PREC    Precision-at-n performance
%   ADJ     Precision-at-n performance adjusted by chance
%
% DESCRIPTION
% Compute the Precision-at-n and adjusted Precision-at-n of a dataset.
%
% SEE ALSO
% dd_error, dd_roc, dd_f1

%
% Copyright: H. O. Marques, hom@icmc.usp.br
% Data Pattern Analysis Lab. 
% ICMC-USP
%

function [e, adj] = dd_precatn(x,w)

% Do it the same as testc:
% When no input arguments are given, we just return an empty mapping:
if nargin==0
	
	e = prmapping(mfilename,'fixed');
    e = setname(e,'PREC');
	return

elseif nargin == 1
	% Now we are doing the actual work, our input is a mapped dataset:
	[It,Io] = find_target(x);
 	N = [length(It), length(Io)];
	
    ranks = +x;
    ranks = ranks(:,1);
    [~, ids] = sort(ranks);
	e = size(intersect(ids(1:N(2)), Io), 1) / N(2);
	ev = N(2)/(N(1)+N(2));
	adj = (e - ev) / (1 - ev);

else

	ismapping(w);
	istrained(w);

	[e, adj] = feval(mfilename,x*w);

end

return