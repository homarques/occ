%RSSCC Trainable random subspace combining classifier
%
%    W = RSSCC(A,CLASSF,NFEAT,NCLASSF)
%    W = A*RSSCC([],CLASSF,NFEAT,NCLASSF)
%    W = A*RSSCC(CLASSF,NFEAT,NCLASSF)
%
% INPUT
%   A       Dataset
%   CLASSF  Untrained base classifier. default NMC
%   NFEAT   Number of features for training CLASSF
%   NCLASSF Number of base classifiers
% 
% OUTPUT
%   W       Combined classifer
%
% DESCRIPTION
% This procedure computes a combined classifier consisting out of NCLASSF
% base classifiers, each trained by a random set of NFEAT features of A.
% W is just the set of base classifiers and still needs a combiner, e.g.
% use W*VOTEC. PRTools uses by default MAXC. A trained combiner might be
% considered as well, e.g. W = A*(RSSCC*QDC([],[],1e-6))
%
% The default subspace dimension (NFEAT) is 10% of the size of the training 
% set A with a minimum of 2. The default number of classifiers is the
% dimension of the training set divided by the subspace dimension with a
% minimum of 10. 
%
% SEE ALSO (<a href="http://37steps.com/prtools">PRTools Guide</a>)
% DATASETS, MAPPINGS, PARALLEL, VOTEC, NMC, QDC

function w = rsscc(varargin)
  
	mapname = 'RandSubSpaceCC';
  argin = shiftargin(varargin,'prmapping');
  argin = setdefaults(argin,[],nmc,[],[]);
  
  if mapping_task(argin,'definition')
    w = define_mapping(argin,'untrained',mapname);
    
  elseif mapping_task(argin,'training')			% Train a mapping.
  
    % handle inputs
    [a,classf,nfeat,nclassf] = deal(argin{:});
    [m,k] = size(a);
    nfeat = setdefaults(nfeat,max(round(m/10),2));
    nclassf = setdefaults(nclassf,max(ceil(k/nfeat),10));     
    
    % determine number of classifiers and their feature sets
    if nfeat >= k  % allow for small feature sizes (k < nfeat)
      nfeat = k;   % use all features
      nclassf = 1; % compute a single classifier
    end
    nsets = ceil(nfeat*nclassf/k);
    featset = zeros(k,nsets);
    for j=1:nsets
      featset(:,j) = randperm(k)';
    end
    featset = featset(1:nfeat*nclassf);
    featset = reshape(featset,nclassf,nfeat);

    % determine the classifier
    s = sprintf('Compute %i classifiers: ',nclassf);
    prwaitbar(nclassf,s);
    starttime = overtime;
    w = cell(1,nclassf);
    for j=1:nclassf
      prwaitbar(nclassf,j,[s num2str(j)]);
      w{j} = a*(featsel(k,featset(j,:))*classf);
      if overtime(starttime)
        prwarning(2,'Random subspace generation stopped by PRTIME with %i classifiers',j);
        break;
      end
    end
    w = w(1:j);
    prwaitbar(0)
    w = stacked(w);
    
  end
  
return
	
	
		