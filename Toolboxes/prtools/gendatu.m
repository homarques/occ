%GENDATU Generation of a 2D classification problem: uniform circle and blob
% 
%   A = GENDATU(N,S1,S2)
% 
% INPUT
%   N       Dataset size, or 2-element array of class sizes (default: [50 50]).
%   S1      Width of the circle, default 0.2
%   S2      Radius of the blob, default 0.6.
%
% OUTPUT
%   A       Dataset.
%
% DESCRIPTION
% Generation of a two-class problem. The first class is a uniformly
% distributed circle with width S1 and outer radius one. The second class
% is a uniformly distributed circle in the origin with radius S2.
%
% SEE ALSO (<a href="http://37steps.com/prtools">PRTools Guide</a>)
% DATASETS, PRDATASETS

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com

function a = gendatu(varargin)

  [N,s1,s2] = setdefaults(varargin,[50 50],0.2,0.6);

	% Set equal priors and generate random class sizes according to these.
	p = [0.5 0.5]; N = genclass(N,p);	
  
  a = circle2d(N(1),s1);
  a = [a; circle2d(N(2),1)*s2];
  a = prdataset(a,genlab(N));
  
return
