%DISNORM Trainable mapping for dissimilarity matrix normalisation
%
% 	V = DISNORM(D,OPT)
% 	V = D*DISNORM([],OPT)
% 	V = D*DISNORM(OPT)
%   F = E*V
%
% INPUT
%   D 	 Dissimilarity matrix, double, prdataset or disdataset
%   E    Matrix to be normalized, e.g. D itself
% 	OPT  'max' : maximum dissimilarity is set to 1 by global rescaling
%        'mean': average dissimilarity is set to 1 by global rescaling (default)
%
% OUTPUT
%   V 	Trained mapping
%   F  	Normalized dissimilarity data
%
% DESCRIPTION
% Operation on dissimilarity matrices, like the computation of classifiers
% in dissimilarity space, may depend on the scaling of the dissimilarities
% (a single scalar for the entire matrix). This routine computes a scaling
% for a giving matrix, e.g. a training set and applies it to other
% matrices, e.g. the same training set or based on a test set.
%
% There is a fixed version of this mapping: DNORM
%
% SEE ALSO (<a href="http://37steps.com/distools">DisTools Guide</a>)
% DATASETS, MAPPINGS, DNORM

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com

function out = disnorm(varargin)

	argin = shiftargin(varargin,'char');
  argin = setdefaults(argin,[],'mean');
  if mapping_task(argin,'definition')
    % call like U=disnorm or U=disnorm('mean') or U=disnorm([],'mean')
    out = define_mapping(argin,'untrained');
    out = setname(out,'Disnorm');
  elseif mapping_task(argin,'training')
    % call like W=disnorm(D,'mean') or W=D*U
    [D,opt] = deal(argin{:});
    if ~isdataset(D)
      D = prdataset(D,1);
      D = setfeatlab(D,getlabels(D));
    end
    if strcmpi(opt,'mean')
      n = size(D,1);
      m = sum(sum(+D))/(n*(n-1));
    elseif strcmpi(opt,'max')
      m = max(D(:));
    else
      error('Wrong OPT')
    end
    out = prmapping(mfilename,'trained',{m},[],size(D,2),size(D,2));
  elseif mapping_task(argin,'trained execution')
    % call like E=D*W
    [D,W] = deal(argin{:});
    m = getdata(W,1);
    out = D./m;
  else
    error('Illegal input')
  end			
	
