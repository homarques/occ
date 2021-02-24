%TESTK Error estimation of the K-NN rule
% 
% 	E = TESTK(A,K,T)
%
% INPUT
% 	A 	Training dataset
% 	K 	Number of nearest neighbors (default 1)
% 	T 	Test dataset (default [], i.e. find leave-one-out estimate on A)
%
% OUTPUT
% 	E 	Estimated error of the K-NN rule
%
% DESCRIPTION  
% Tests a dataset T on the training dataset A using the K-NN rule and
% returns the classification error E. In case no set T is provided, the
% leave-one-out error estimate on A is returned.
% 
% The advantage of using TESTK over TESTC is that it enables leave-one-out 
% error estimation. However, TESTK is based on just counting errors and
% does not weight with testobject priors.
% 
% SEE ALSO (<a href="http://37steps.com/prtools">PRTools Guide</a>)
% DATASETS, KNNC, KNN_MAP, TESTC

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% $Id: testk.m,v 1.4 2009/07/22 19:29:41 duin Exp $

% to be improved using fnnc

function [e,labels] = testk(a,knn,t)

	if (nargin < 2)	
		knn = 1; 
	end

	% Calculate the KNN classifier.

	a = seldat(a);   % get labeled objects only

	[m,k] = size(a); 
  lablist = getlablist(a);

	if (nargin <= 2)						   % Leave-one-out error estimate.
    % should be made faster using fnnc
    if knn > 1
      w = knnc(a,knn); % should be replaced by fnnc for knn = 1
      d = knn_map([],w);				   % Posterior probabilities of KNNC(A,KNN).
      [~,J] = max(d,[],2);		     % Find the maximum.
      e = nlabcmp(J,getnlab(d))/m; % Calculate error: compare numerical labels.
    else
      w = fnnc(a,1);
      d = a*w;
      e = d*testd;
      if nargout > 1
        [~,J] = max(+d,[],2);
        labels = lablist(J,:);
      end
    end
    if nargout > 1
      labels = lablist(J,:);
    end

  else												   % Error estimation on tuning set T.

		[n,kt] = size(t);
    if (k ~= kt)
			error('Number of features of A and T do not match.');
    end

    if knn > 1
      % should be made faster using fnnc
      w = knnc(a,knn);      % should be replaced by fnnc for knn = 1
      d = knn_map(t,w); 		% Posterior probabilities of T*KNNC(A,KNN).
      [~,J] = max(d,[],2); 	% Find the maximum.
      e = nlabcmp(getlab(t),lablist(J,:))/n;
      if nargout > 1
        labels = lablist(J,:);
      end
    else
      w = fnnc(a);
      d = t*w;
      e = d*testd;
      if nargout > 1
        [~,J] = max(+d,[],2);
        labels = lablist(J,:);
      end
    end
  end

return
