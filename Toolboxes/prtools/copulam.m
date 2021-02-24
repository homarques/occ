%COPULAM Copula mapping
%
%   [W,V] = COPULAM(A,K)
%   [W,V] = A*COPULAM
%   C = B*W
%
% INPUT
%   A    Dataset, used for training the mapping
%   B    Dataset, same dimensionality as A, to be mapped
%   K    Desired output dimensionality, default dimensionality of A.
%
% OUTPUT
%   W    Trained mapping
%   V    Trained inverse mapping
%   C    Copula transformed dataset
%
% DESCRIPTION
% The copula of a dataset transforms for every dimension every feature
% value into the value of its cumulative feature density. So, A*W executes
% the transform on the original data. A*W*V returns A again. This mapping
% uses MAPSD in order to apply it on another dataset B of the same
% dimensionality. It thereby creates an approximation trained by A.
%
% If K is given, first a PCA to K dimensions is performed.
%
% SEE ALSO
% DATASETS, MAPPINGS, PCAM, MDS, TSNEM, MAPSD

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com


function [out1,out2] = copulam(varargin)

  argin = shiftargin(varargin,'scalar');
  argin = setdefaults(argin,[],[]);
  if mapping_task(argin,'definition')
    out1 = define_mapping(argin,'untrained');
  elseif mapping_task(argin,'training')
    [a,k] = deal(argin{:});
    if ~isempty(k)
      v = pcam(+a,k);
      x = +a*v;
    else
      x = +a;
    end
    [~,r] = sort(x,1);
    [~,r] = sort(r,1);
    if nargout < 2
    	out1 = mapsd(a,r/size(a,1));
    else
      [out1,out2] = mapsd(a,r/size(a,1));
      out2 = setname(out2,'inverse_copulam');
    end
  else
    error('Illegal call');
  end
