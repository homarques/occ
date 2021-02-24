%INDNN Find indices of nearest neighbors
%
%   IND = INDNN(TEST,TRAIN,LOO)
%   IND = TEST*INDNN([],TRAIN,LOO) for batch processing
%   IND = INDNN(TEST,CLASSF,LOO)
%   IND = TEST*INDNN([],CLASSF,LOO) for batch processing
% 
% INPUT
%   TEST   Double array or PRDATASET with object feature vectors
%   TRAIN  Double array or PRDATASET with object feature vectors
%   CLASSF Trained PRTools classifier, either KNNC or NMC.
%   LOO    Logical, should be TRUE in case trainset and testset are
%          identical to perform Leave-One-Out processing
%
% OUTPUT
%   IND   Column vector with indices pointing for every object in TEST to
%         the nearest neighbor of a trainset.
%
% DESCRIPTION
% This routine is optimised for speed and size to perform a nearest
% neighbor search by the standard PRTools distance routine DISTM. The
% training set may be given explicitly by TRAIN or implicitly by a trained
% KNNC or NMC classifier. The latter stores class means which are useful in
% a kmeans clustering, see PRKMEANS
%
% SEE ALSO
% DATASETS, MAPPINGS, KNNC, NMC, PRKMEANS

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com

function ind = indnn(testset,trainset,loo)

  if nargin < 3, loo = false; end
  if ismapping(trainset) % possible knnc
    if strcmp(getmapping_file(trainset),'knn_map')
      trainset = getdata(trainset,1);
    elseif strcmp(getmapping_file(trainset),'normal_map')
      trainset = getdata(trainset,'mean');
    else
      error('Unsupported data type')
    end
  end
  if isempty(testset)
    ind = prmapping('indnn','fixed',trainset);
  else
    batch = ceil(prmemory/(20*size(trainset,1)));
    testset  = +testset;
    trainset = +trainset;
    if loo && ~isequal(trainset,testset)
      error('Trainset and testset should by identical for LOO processing')
    end
    n = 0;
    m = size(testset,1);
    ind = zeros(m,1);
    t = sprintf('Finding nearest neighbors for %i objects: ',m);
    prwaitbar(m,t)
    for i=1:floor(m/batch)
      d = distm(testset(n+1:n+batch,:),trainset);
      if loo
          d(:,n+1:n+batch) = d(:,n+1:n+batch)+diag(inf(1,batch));
      end
      [~,ind(n+1:n+batch)] = min(d,[],2);
      n = n+batch;
      prwaitbar(m,n,[t num2str(n)]);
    end
    d = distm(testset(n+1:m,:),trainset);
    if loo
      d(:,n+1:m) = d(:,n+1:m) + diag(inf(1,m-n));
    end
    [~,ind(n+1:m)] = min(d,[],2);
    prwaitbar(0);
        
  end

return