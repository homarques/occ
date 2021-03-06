%SVDD Support Vector Data Description
% 
%       W = SVDD(A,FRACREJ,SIGMA)
%       W = A*SVDD([],FRACREJ,SIGMA)
%       W = A*SVDD(FRACREJ,SIGMA)
%
% INPUT
%   A         One-class dataset
%   FRACREJ   Error on the target class (default = 0.1)
%   SIGMA     Width parameter in the RBF kernel (default = 5)
%
% OUTPUT
%   W         Support vector data description
% 
% DESCRIPTION
% Optimizes a support vector data description for the dataset A by 
% quadratic programming. The data description uses the Gaussian kernel
% by default. FRACREJ gives the fraction of the target set which will
% be rejected, when supplied FRACERR gives (an upper bound) for the
% fraction of data which is completely outside the description.
%
% Note: this version of the SVDD is not compatible with older dd_tools
% versions. This is to make the use of consistent_occ.m possible.
%
% Further note: this classifier is one of the few which can actually
% deal with example outlier objects!
% 
% REFERENCE
%@article{Tax1999c,
%	author = {Tax, D.M.J. and Duin, R.P.W},
%	title = {Support vector domain description},
%	journal = {Pattern Recognition Letters},
%	year = {1999},volume = {20},
%	number = {11-13},pages = {1191-1199}
%}
%
% SEE ALSO
% incsvdd, svdd_optrbf, dd_roc.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
  
%function W = svdd(a,fracrej,sigma)
function W = svdd(varargin)

argin = shiftargin(varargin,'scalar');
argin = setdefaults(argin,[],0.1,5);

if mapping_task(argin,'definition')
   W = define_mapping(argin,'untrained','SVDD');

elseif mapping_task(argin,'training')
   [a,fracrej,sigma] = deal(argin{:});
   a = target_class(a);

	c = 1/(size(a, 1)*fracrej(1));
	s = 1/(sigma^2);
	model = svmtrain(a.nlab, +a, ['-s 5 -t 2 -g ', num2str(s), ' -c ', num2str(c), ' -e 1e-16 -q ']);
	
	% store the results
	W.model = model;
    [~, ~, W.out] = svmpredict(repmat(0, size(a,1), 1), +a, W.model, '-q');
	W.s = sigma;
	W.threshold = 0;
	W = prmapping(mfilename,'trained',W,char('target','outlier'),size(a,2),2);
	W = setname(W,'SVDD');
elseif mapping_task(argin,'trained execution') %testing

   [a,fracrej] = deal(argin{1:2});
	W = getdata(fracrej);
	m = size(a,1);

	% check if alpha's are OK
	[~, ~, out] = svmpredict(repmat(0, m, 1), +a, W.model, '-q');
    
    newout = [out repmat(W.threshold,m,1)];

	% Store the distance as output:
	W = setdat(a,-newout,fracrej);
	W = setfeatdom(W,{[-inf inf; -inf inf] [-inf inf; -inf inf]});
else
   error('Illegal call to SVDD.');
end
return


