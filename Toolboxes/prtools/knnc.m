%KNNC K-Nearest Neighbor Classifier
%
%   [W,K,E] = KNNC(A,K)
%   [W,K,E] = KNNC(A)
%
% INPUT
%   A  Dataset
%   K  Number of the nearest neighbors (optional; default: K is 
%      optimised with respect to the leave-one-out error on A)
%
% OUTPUT
%   W  k-NN classifier 
%   K  Number of the nearest neighbors used
%   E  The leave-one-out error of the KNNC
%
% DESCRIPTION  
% Computation of the K-nearest neighbor classifier for the dataset A. 
% The resulting classifier W is automatically evaluated by KNN_MAP.
%
% For multi-class problems with many classes (e.g. > 100) evaluation is
% slow if K = 1. For that situation the use of FNNC may be considered.
%
% Warning: class prior probabilities in A are neglected.
%
% SEE ALSO (<a href="http://37steps.com/prtools">PRTools Guide</a>)
% MAPPINGS, DATASETS, KNN_MAP, FNNC

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: knnc.m,v 1.4 2007/04/13 09:29:57 duin Exp $

function [W,knn,e,ek] = knnc(a,knn)

  if (nargin < 2), knn = [];  end

  % No input data, return an untrained classifier.
  if (nargin == 0) || (isempty(a))
    W = prmapping('knnc',knn);
    if (isempty(knn))
      W = setname(W,'K-NN');
    else
      W = setname(W,[num2str(knn) '-NN']);
    end
    W = setuser(W,'pe_mapping','type'); % can handle pe_mappings
    return; 
  end

  % training
  islabtype(a,'crisp','soft');
  
  % remove too small classes, escape in case no two classes are left
  [a,m,k,c,lablist,K,W] = cleandset(a,1); 
  if ~isempty(W), [knn,e,ek] = deal('NaN','NaN','NaN'); return; end
  
  a    = testdatasize(a);
  a    = testdatasize(a,'objects');
  nlab = getnlab(a);

  if (isempty(knn))              

    % Optimise knn by the LOO procedure.
    [num,bat] = prmem(m,m);
    z = zeros(1,m);
    N = zeros(c,m);
    s = sprintf('Compute distance matrix in %i batches: ',num);
    prwaitbar(num,s);
    for i = 0:num-1              % Compute the distance matrix part by part
      prwaitbar(num,i+1,[s int2str(i+1)]);
      if (i == num-1)            % depending on the available memory.
        nn = m - num*bat + bat;
      else
        nn = bat;
      end
      I = [i*bat+1:i*bat+nn];
      D=+distm(a,a(I,:));         
      [Y,L] = sort(D);          % Sort in columns.

      % L are the labels of the nearest-to-further neighbors for the objects from I.
      L = nlab(L)';              
      Ymax = zeros(nn,m);       
      Yc = zeros(nn,m);
      if islabtype(a,'soft')
        error('Soft labels not yet allowed for optimisation of k')
      end
      for j = 1:c
        Y = +(L == j);          % Mark by 1 the positions of the class j in 
        for n = 3:m             % the ordered distances to the objects from I.  
          Y(:,n) = Y(:,n-1) + Y(:,n);
        end
        % Y is NN x M; for objects from I, Y(:,P) counts all the objects 
        % from the class j that are within the first P nearest neighbors.
        Y(:,1) = zeros(nn,1);   
        J = Y > Ymax;            % J is the index of the 'winning' class 
        Ymax(J) = Y(J);          % within the first nearest neighbors.
        Yc(J) = j*ones(size(Yc(J)));
      end
      z = z + sum(Yc == repmat(nlab(I),1,m),1); % number of objects correctly classified for knn = 0,1,2,...
    end
    prwaitbar(0);

    name = 'K-NN';
    [e,knn] = max(z); % select best neighborhood size
    knn = knn-1;      % correct for leave-one-out
    knn = max(knn,1); % correct for pathological case knn = 0 (it appeared to exist!: all objects were
                      % incorrectly classified for all neighbood sizes).
    e = 1 - e/m;
    ek = 1 - z/m;
    ek(1) = []; 
  
  else                          % knn is fixed
    if (knn > m)
      error('The number of neighbors should not be larger than number of training objects.')
    end
    if (nargout > 2)
      e = testk(a,knn);
    end
    name = [num2str(knn) '-NN'];
  end

  W = prmapping('knn_map','trained',{a,knn},getlablist(a),k,c);
  W = setname(W,name);
  W = setuser(W,'pe_mapping','type'); % can handle pe_mappings
  W = allclass(W,lablist,K);     % complete classifier with missing classes
  W = setcost(W,a);

return
