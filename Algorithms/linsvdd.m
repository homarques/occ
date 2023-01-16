%SVDD Linear Support Vector Data Description
% 
%       W = SVDD(A)
%
% INPUT
%   A         One-class dataset
%
% OUTPUT
%   W         Support vector data description
% 
% DESCRIPTION
% Optimizes a support vector data description for the dataset A by 
% quadratic programming. The data description uses the linear kernel.
% 
  
function W = svdd(varargin)

argin = shiftargin(varargin,'scalar');
argin = setdefaults(argin,[]);

if mapping_task(argin,'definition')
   W = define_mapping(argin,'untrained','SVDD');

elseif mapping_task(argin,'training')
   [a,fracrej,sigma] = deal(argin{:});
   a = target_class(a);

   c = 1/(size(a, 1)*0);
   model = svmtrain(a.nlab, +a, ['-s 5 -t 0 -c ', num2str(c), ' -e 1e-16 -q ']);
	
   % store the results
   W.model = model;
   W.sv = full(model.SVs);
   W.alf = model.sv_coef;
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


