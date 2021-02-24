%STATSNBC Stats Naive Bayes Classifier (Matlab Stats Toolbox)
%
%   W = STATSNBC(A,'PARAM1',val1,'PARAM2',val2,...)
%   W = A*STATSNBC([],'PARAM1',val1,'PARAM2',val2,...)
%   D = B*W
%
% INPUT
%   A          Dataset used for training
%   PARAM1     Optional parameter, see NAIVEBAYES.FIT
%   B          Dataset used for evaluation
%
% OUTPUT
%   W          Naive Bayes classifier  
%   D          Classification matrix, dataset with posteriors
%
% DESCRIPTION
% This is the PRTools interface to the NaiveBayes classifier of the Matlab
% Stats toolbox. See there for more information. It is assumed that objects
% labels, feature labels and class priors are included in the dataset A.
%
% After Matlab R2015a PRTools uses FITCNB instead of NAIVEBAYES
%
% SEE ALSO (<a href="http://37steps.com/prtools">PRTools Guide</a>)
% DATASETS, MAPPINGS, NAIVEBAYES, FITCNB, NAIVEBC

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com

function W = statsnbc(varargin)

  checktoolbox('NaiveBayes');
  name = 'StatsNaiveBayes';
  
  if mapping_task(varargin,'definition')
    W = define_mapping(varargin,[],name);
	elseif mapping_task(varargin,'training')
    A = varargin{1};
    
    % remove too small classes, escape in case no two classes are left
    [A,m,k,c,lablist,L,W] = cleandset(A,2); 
    if ~isempty(W), return; end
    
    data    = +A;
    labels  = getlabels(A);
    prior   = getprior(A);
    if verLessThan('matlab', 'R2015b')
      model   = NaiveBayes.fit(data,labels,'prior',prior,varargin{2:end});
    else
      model   = fitcnb(data,labels,'prior',prior,varargin{2:end});
    end
    W = trained_mapping(A,model);
    W = allclass(W,lablist,L);     % complete classifier with missing classes
  else % evaluation
    [A,W]    = deal(varargin{:});
    model    = getdata(W);
    if verLessThan('matlab', 'R2015b')
      post     = posterior(model,+A);
    else
      [~,post,~]= predict(model,+A);
    end
    W        = setdat(A,post,W);
  end
  
return