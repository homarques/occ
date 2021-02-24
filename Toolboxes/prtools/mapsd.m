%MAPSD Train mapping between two representations
%
%    [W,V] = MAPSD(S,D,P,Q)
%
% INPUT
%   S  - Dataset, source representation, typically high-dimensional
%   D  - Dataset, destination representation, typically low-dimensional
%   P  - Non-linearity parameter for W between 0 and 1, default 0.01
%   Q  - Non-linearity parameter for V between 0 and 1, default 0.01
%
% OUTPUT
%   W  - Mapping, such that D = S*W
%   V  - Mapping, such that S = D*V
%
% DESCRIPTION
% This mapping is useful to generalise mappings like MDS and TSNEM such
% that they can be applied to new datasets. Once by such routines a proper
% low-dimensional representation D is found for the original dataset S then 
% W can be applied to find an approximate representation D2 of a similar to
% S source representation S2 by D2 = S2*W.
%
% SEE ALSO
% DATASETS, MAPPINGS, MDS, TSNEM

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com

function [out,v] = mapsd(varargin)

  argin = setdefaults(varargin,[],[],0.01,0.01);
  if mapping_task(argin,'definition')
    % define untrained mapping
    out = define_mapping(argin,'untrained');
    
  elseif mapping_task(argin,'training')
    [a,b,powa,powb] = deal(argin{:});
    a = +a;
    b = +b;
    w = prpinv(sqrt(distm(a)).^powa)*b;
    out = trained_mapping(a,{w,a,powa},size(w,2));
    if nargout > 1
      v = prpinv(sqrt(distm(b)).^powb)*a;
      v = trained_mapping(b,{v,b,powb},size(v,2));
    end

  elseif mapping_task(argin,'trained execution')
    % execution the mapping on new data
    % retrieve inputs as given by PRTools
    [b,w] = deal(argin{1:2}); % test data and mapping
    [v,a,pow] = getdata(w);   % get transform, train data and power
    
    % map and return
    if isdataset(b) 
      % if input is dataset, return dataset
      out = setdata(b,(sqrt(distm(b,a)).^pow)*v);
    else
      % otherwise return doubles
      out = (sqrt(distm(b,a)).^pow)*v;
    end
    
  else
    error('Illegal call');
  end