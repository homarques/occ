%UDC Uncorrelated normal based quadratic Bayes classifier (BayesNormal_U)
% 
%  W = UDC(A)
%  W = A*UDC
% 
% INPUT
%  A  input dataset
%
% OUTPUT
%  W   output mapping
%
% DESCRIPTION
% Computation a quadratic classifier between the classes in the 
% dataset A assuming normal densities with uncorrelated features.
% This is similar to NAIVEBC assuming normal distributions for the
% features.
%
% The use of probabilistic labels is supported.  The classification A*W is
% computed by normal_map.
% 
% EXAMPLES
% PREX_DENSITY
%
% SEE ALSO (<a href="http://37steps.com/prtools">PRTools Guide</a>)
% MAPPINGS, DATASETS, NMC, NMSC, LDC, QDC, QUADRC, NORMAL_MAP, NAIVEBC

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: udc.m,v 1.6 2007/06/05 12:45:44 duin Exp $

function W = udc(a)

  mapname = 'Bayes-Normal-U';
	if nargin == 0
		W = prmapping(mfilename);
		W = setname(W,mapname);
		return
	end

	islabtype(a,'crisp','soft');
  
  % remove too small classes, escape in case no two classes are left
  [a,m,k,c,lablist,L,W] = cleandset(a,1); 
  if ~isempty(W), return; end

	[U,G] = meancov(a); %computing mean and covariance matrix
	for j = 1:c
		G(:,:,j) = diag(diag(G(:,:,j)));
  end
  
	w.mean       = +U;
  w.cov        = repmat(eye(k),[1,1,c]);
	w.cov        = G;
  w.prior      = getprior(a);
  
	W = normal_map(w,getlablist(a),k,c);
	W = setname(W,mapname);
  W = allclass(W,lablist,L);     % complete classifier with missing classes
	W = setcost(W,a);

return

