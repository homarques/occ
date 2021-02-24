%CIRCLE2D Generate circle dataset
%
%   A = CIRCLE2D(N,S,TYPE)
%
% INPUT
%   N    Number of points to be generated. Default N = 100;
%   S    Width (in case TYPE is 'uniform') or standard deviation (in case
%        TYPE is 'normal'). Default S = 0.1.
%  TYPE  String with distribution type: 'u' (default) or 'uniform' for a 
%        uniform distribution, 'n' or 'normal' for a normal distribution.
%
% OUTPUT
%   A    Nx2 matrix op 2D points
%
% DESCRIPTION
% Either a uniform 2D circle of width S is generated (0 <= S <= 1) with
% outer radius one, or a unit circle with normally distributed points
% perpendicular to it. In this case S might be larger than one.

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com

function a = circle2d(varargin)

[n,r,type] = setdefaults(varargin,100,0.1,'u');

type = lower(type);
switch type
  case {'u','uniform'}
    if r < 0 || r > 1
      error('Radius should be between 0 and 1');
    end
    
    if r > 0
      r = sqrt(r);
      s = (1-r)/r;
      x = randn(n,2);
      y = sum(x.*x,2);
      a = x.*repmat(sqrt((s+exp(-y/2))/(1+s))./sqrt(y),1,2);
    else
      alf = rand(n,1)*2*pi;
      a = [sin(alf) cos(alf)];
    end
  case {'n','normal'}
    d = randn(n,1)*r;
    alf = rand(n,1)*2*pi;
    a = [(1+d).*sin(alf) (1+d).*cos(alf)];
  otherwise
    error('Unknown type')
end
    