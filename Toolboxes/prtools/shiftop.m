%SHIFTOP Shift operating point of classifier
%
%   V = SHIFTOP(D,E,C)
%   V = D*SHIFTOP(E,C);
%   V = D*SHIFTOP(TYPE,C);
%   W = A*(U*SHIFTOP(E,C));
%
% INPUT
%   D      Dataset, classification matrix (two classes only). D = A*U.
%   E      Desired error class C for D*TESTC
%   TYPE   Minimum error TYPE
%   C      Index of desired class (default: C = 1)
%   A      Dataset used to train a classifier U and the shift of the
%          operaing point.
%   U      Untrained classifier.
%
% OUTPUT
%   V      Mapping, such that E = TESTC(D*S,[],LABEL)
%   W      Tained classifier with shifted operating point.
%
% DESCRIPTION
% If D = A*W, with A a test dataset and W a trained classifier, then an ROC
% curve can be computed and plotted by ER = PRROC(D,C), PLOTE(ER). C is the
% desired class number for which the error is plotted along the horizontal 
% axis.
% The classifier W can be given any operating point along this curve by
% W = W*SHIFTOP(D,E,C).
% Alternatively, an overall error TYPE can be optimised. Currently we
% have:
%     TYPE = 'minerr'  minimum classification error
%     TYPE = 'eer'     equal error rate
%
% The class index C refers to its position in the label list of the dataset
% A used for training the classifier that yielded D. The relation to LABEL
% is LABEL = CLASSNAME(A,C); C = GETCLASSI(A,LABEL).
%
% In case the same dataset A is used to train an untrained classifier U as
% well as to determine D to 
%
% SEE ALSO (<a href="http://37steps.com/prtools">PRTools Guide</a>) 
% DATASETS, MAPPINGS, TESTC, PRROC, PLOTE, CLASSNAMES, GETCLASSI

function out = shiftop(varargin)

  argin = shiftargin(varargin,{'scalar','char'});
  argin = setdefaults(argin,[],0.05,1);

  if mapping_task(argin,'definition')
    
    out = define_mapping(argin,'untrained');
    
  else
    
    [d,e,n] = deal(argin{:});
    if any(any(+d)) < 0
      error('Classification matrix should have non-negative entries only')
    end

  [m,c] = size(d);
    if c ~= 2
      error('Only two-class classification matrices are supported')
    end

    if nargin < 3 || isempty(n)
      n = 1;
    end

    s = classsizes(d);
    if isa(e,'char')
       % match the true labels and classifier featlab:
       nlab = renumlab(getlabels(d),getlablist(d));
       truelab = (nlab==n);
       % sort outputs:
       out = d*normm;
       [sout,I] = sort(out(:,n));
       truelab = truelab(I);
       % the error for all thresholds:
       e1 = cumsum(truelab); e1 = e1/e1(end);
       e2 = cumsum(truelab-1); e2 = 1-e2/e2(end);
       switch e
       case 'minerr'
          % find the minimum:
          [minerr,J] = min(e1+e2);
          alf = sout(J);
       case 'eer'
          % find when they are equal:
          [mindf,J] = min(abs(e1-e2));
          alf = sout(J);
       otherwise
          error('Error type %s is not defined.',e);
       end
       % define rescaling
       if (n==1)
          out = diag([(1-alf)/alf 1]);
       else
          out = diag([1 (1-alf)/alf]);
       end
    else
       d = seldat(d,n)*normm;
       [dummy,L] = sort(+d(:,n));
       k = floor(e*s(n));
       k = max(k,1);    % avoid k = 0
       alf = +(d(L(k),:)+d(L(k+1),:))/2;
       if n == 1
          out = diag([alf(2)/alf(1) 1]);
       else
          out = diag([1 alf(1)/alf(2)]);
       end
    end

    out = affine(out);
    out = setlabels(out,getfeatlab(d));

  end
