%ONEC Single class classifier
%
%   W = ONEC(A)
%   W  = A*ONEC
%
% INPUT
%   A    Dataset
%
% OUTPUT
%   W    Trained classifier
%
% DESCRIPTION
% This classifier serves as an escape to irregular situations, e.g. when a 
% dataset contains objects of a single class. It creates a trained
% classifier that assigns all objects to a one class. In case the priors
% of A are set this will be the class with the maximum prior probability
% times the classsizes. In case the priors of A are not set objects to be
% classified will be assigned to the most frequent class in A. 
%
% SEE ALSO (<a href="http://37steps.com/prtools">PRTools Guide</a>)
% MAPPINGS, DATASETS

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com

function out = onec(varargin)

  mapname = 'OneClassC';
  if mapping_task(varargin,'definition')
    
    out = define_mapping({},'untrained',mapname);
    
	elseif mapping_task(varargin,'training')			% Train a mapping.
 
    a = varargin{1};
    lablist = getlablist(a);
    if isempty(a,'prior')
      [dummy,n] = max(classsizes(a));
    else
      if size(a,1) == 0
        [dummy,n] = max(getprior(a));
      else
        [dummy,n] = max(getprior(a).*classsizes(a));
      end
    end
    out = trained_classifier(a,n);
    
  else % execution
    
    [a,w] = deal(varargin{:});
    n = getdata(w,1);
    d = zeros(size(a,1),size(w,2));
    d(:,n) = ones(size(a,1),1);
    out = setdat(a,d,w);
    
  end
    
return