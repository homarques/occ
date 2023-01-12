%SVDD Support Vector Data Description
% 
%       W = LIBSVDD(A,FRACREJ,SIGMA)
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
  
function W = libsvdd(varargin)

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

   [~, ~, out] = svmpredict(repmat(0, m, 1), +a, W.model, '-q');
   
   newout = [out repmat(W.threshold,m,1)];

   % Store the distance as output:
   W = setdat(a,-newout,fracrej);
   W = setfeatdom(W,{[-inf inf; -inf inf] [-inf inf; -inf inf]});
   
else
   error('Illegal call to SVDD.');
end
return


