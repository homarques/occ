%DYADIC Dyadic datafile operations
%
%  C = DYADIC(A,P,B,Q)
%
% Computes C = P*A + Q*B
%
% This datafile operation is, like others, either stored as
% a preprocessing or as a postprocessing for datafiles using
% a call to DYADICM.
%
% Note that in P a function name can be stored and in Q a cell
% array with a set of parameters. In that case effectively 
% feval(p,a1,a2,q{:}) will be executed inside DYADICM.
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% DATAFILES, DYADICM

function c = dyadic(a,p,b,q)

	
  %if nargin < 4, q = 1; end
  if nargin < 4, q = []; end
  
	isdatafile(a);
	isdatafile(b);
	fsize = getfeatsize(a);
	
	if isempty(a.postproc) && isempty(b.postproc)
		c = [a b];
		c = addpreproc(c,'dyadicm',{p,q});
	else
		w = dyadicm([],p,q,fsize);
		w = setsize_in(w,2*prod(fsize));
		c = [a b]*w;
	end
						
	%c.prdataset = setfeatsize(c.prdataset,fsize);

return
