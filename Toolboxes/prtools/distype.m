%DISTYPE Set/get global for dissimilarity computations
%
%   TYPE = DISTYPE(TYPE,PARS)
%
% INPUT
%   TYPE Desired type used for distance computations by DISTM
%        - 'SquaredEuclid', default for TYPE = [], the squared Euclidean
%          distance, which is the original default of DISTM.
%        - 'CityBlock', the city-block distance.
%        - 'Minkowski'. the Minkowski distance with parameter PARS(1)
%        See further all options of PDIST2. TYPE is case insensitive.
%   PARS - Additional parameters used by PDIST2
%
%DESCRIPTION
% Original PRTOOLS uses almost everywhere DISTM for distance computations.
% Later Matlab introduced the more general routine PDIST2. In the more
% recent versions it is equally fast or faster than DISTM. Consequently
% DISTM now internally calls PDIST2. By DISTYPE the distance type can be
% set externally.
%
%SEE ALSO
% DISTM, PDIST2

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com

function out = distype(type,varargin)

  global DISTANCETYPE
  if isempty(DISTANCETYPE)
    DISTANCETYPE = {'SquaredEuclid'};
  end
  
  if nargin > 0
    if isempty(type)
      type = 'SquaredEuclid';
    end
    DISTANCETYPE{1} = type;
    if nargin > 1
      DISTANCETYPE(2:numel(varargin)+1) = varargin;
    else
      DISTANCETYPE = DISTANCETYPE(1);
    end
  end
  if nargin == 0 || nargout > 0
    out = DISTANCETYPE{1};
  end
    
    
  