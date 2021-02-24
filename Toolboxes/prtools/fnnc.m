%FNNC Fast Nearest Neighbor Classifier
%
%   W = A*FNNC(LOO)
%   W = FNNC(A,LOO)
%
% DESCRIPTION
% This is a fast version of KNNC([],1), especially useful for many-class
% problems. For reasons of speed it will NOT return proper confidences on
% evaluation. D = B*W will be a 0/1 dataset. Classification results are
% otherwise identical to KNNC([],1).
%
% LOO is a logical that should be TRUE in case W is applied to the same
% dataset (A) to enforce Leave-One-Out processing. Default LOO is FALSE.
%
% SEE ALSO (<a href="http://37steps.com/prtools">PRTools Guide</a>)
% MAPPINGS, DATASETS, KNNC, TESTK

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com

function out = fnnc(varargin)

  argin = shiftargin(varargin,'logical');
  argin = setdefaults(argin,[],false);
  if mapping_task(argin,'definition')
    out = define_mapping(argin,'untrained','1-NN');
  elseif mapping_task(argin,'training')
    [a,loo] = deal(argin{:});
    out = trained_classifier(a,{a,loo});
  elseif mapping_task(argin,'trained execution')
    [a,w] = deal(argin{:});
    [trainset,loo] = getdata(w);
    nlab = getnlab(trainset);
    L = indnn(a,trainset,loo);
    out = zeros(size(a,1),getsize(trainset,3));
    for i=1:size(a,1)
      out(i,nlab(L(i))) = 1;
    end
    out = setdat(a,out,w);
  else
    error('Illegal input')
  end

return
