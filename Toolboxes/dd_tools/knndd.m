%KNNDD K-Nearest neighbour data description method.
% 
%       W = KNNDD(A,FRACREJ,K,METHOD)
%       W = A*KNNDD([],FRACREJ,K,METHOD)
%       W = A*KNNDD(FRACREJ,K,METHOD)
% 
% INPUT
%   A           Dataset
%   FRACREJ     Error on the target class (default = 0.1)
%   K           Number of neighbors (default = [])
%   METHOD      Distance definition (default = 'kappa')
%
% OUTPUT
%   W           k-Nearest neighbor data description
%
% DESCRIPTION
% Calculates the K-Nearest neighbour data description on dataset A.
% Three methods are defined to compute a distance to the dataset using
% the k-nearest neighbours:
%
% METHOD     uses the
% 'kappa'      distance to the k-th nearest neighbor
% 'delta'      distance to the average of the k-nn's
% 'gamma'      average square distance to the k-nn's
%
% When no K is defined, it will be optimized using knn_optk, when it
% is smaller than 0, sqrt(n) will be used.
%
% SEE ALSO
% nndd, dnndd

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

%function W = knndd(a,fracrej,k,method)
function W = knndd(varargin)

argin = shiftargin(varargin,'scalar');
argin = setdefaults(argin,[],0.1,[],'kappa');
  
if mapping_task(argin,'definition')       % Define mapping
   [a,fracrej,k,method] = deal(argin{:});
   W = define_mapping(argin,'untrained','k-NN (%s, k=%d)',method,k);
    
elseif mapping_task(argin,'training')			% Train a mapping.
  
   [a,fracrej,k,method] = deal(argin{:});
	% some checking of datatypes and sizes:
	a = +target_class(a);  % make sure we have a OneClass dataset
	[m,d] = size(a);
	if (m<2)
		warning('dd_tools:InsufficientData',...
			'Dataset contains less than 2 objects');
	end
   if isa(k,'char')
      error('Argument k should define the number of neighbors');
   end
	% the most important thing:
	distmat = sqeucldistm(a,a);

	% is k is not defined, find the optimal k optimizing the loglikelihood:
	if isempty(k)
		k = knn_optk(distmat,d);
	else  %tricky, when k<=0 we use the default sqrt(n) solution...
		if (k<=0)
			k = round(sqrt(m));
		end
	end
	if (k<1)
		warning('dd_tools:KNegativeK', 'K must be positive (>0), set to 1.');
		k = 1;
	end
	[sD,I] = sort(distmat,2);

	% different treatment by different methods:
	switch method
	case 'kappa'
		fit = sD(:,k+1);  
	case 'delta'
		nn = zeros(m,d);
		for i=2:k+1
			nn = nn + a(I(:,i),:);
		end
		nn = (+a - (nn/(k)));
		fit = sum(nn.*nn,2);
	case 'gamma'
		fit = mean(sD(:,(2:(k+1))),2);
	otherwise
		error([mfilename,': Unknown method']);
	end

	%now obtain the threshold:
	thresh = dd_threshold(fit,1-fracrej);
	%and save all useful data:
	W.x = +a;
	W.k = k;
	W.method = method;
	W.threshold = thresh;
	W.scale = mean(fit);
	W = prmapping(mfilename,'trained',W,str2mat('target','outlier'),d,2);
	W = setname(W,sprintf('k-NN OC (%s k=%d)',method,k));

elseif mapping_task(argin,'trained execution')  %testing

   [a,fracrej,k,method] = deal(argin{:});
	W = getdata(fracrej);  % unpack
	[m,d] = size(a);

	%compute:
	distmat = sqeucldistm(+a,W.x);    %dist between train and test
	[sD,I] = sort(distmat,2);

	% different treatment by different methods:
	switch W.method
	case 'kappa'
		ind = sD(:,W.k);
		%ind = sD(:,W.k+1);
	case 'delta'
		nn = zeros(m,d);
		%for i=1:W.k+1
		for i=1:W.k
			nn = nn + W.x(I(:,i),:);
		end
		nn = (+a - (nn/(W.k)));
		ind = sum(nn.*nn,2);
	case 'gamma'
		ind = mean(sD(:,(1:(W.k))),2);
	otherwise
		error([mfilename,': Unknown method']);
	end

	% store the results in the final dataset:
	out = [ind repmat(W.threshold,[m,1])];

	% Store the distance as output:
	W = setdat(a,-out,fracrej);
	W = setfeatdom(W,{[-inf 0; -inf 0] [-inf 0;-inf 0]});
else
   error('Illegal call to knndd');
end
return
