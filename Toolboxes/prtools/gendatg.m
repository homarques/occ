%GENDATG Generation of a 2D classification problem: Gaussian circle and blob
% 
%   A = GENDATG(N,S1,S2)
% 
% INPUT
%   N       Dataset size, or 2-element array of class sizes (default: [50 50]).
%   S1      Standard deviation of the circle, default 0.1
%   S2      Standard deviation of the blob, default 0.3.
%
% OUTPUT
%   A       Dataset.
%
% DESCRIPTION
% Generation of a two-class problem. The first class is a set of uniformly
% distributed points on the unit circle with a normally distributed 
% Gaussian radial deviation. The second class is a Gaussian distributed
% 2D spherical dataset in the origin with standard deviation S2.
%
% SEE ALSO (<a href="http://37steps.com/prtools">PRTools Guide</a>)
% DATASETS, PRDATASETS

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com

function a = gendatg(varargin)

  [N,s1,s2] = setdefaults(varargin,[50 50],0.1,0.3);

	% Set equal priors and generate random class sizes according to these.
	p = [0.5 0.5]; N = genclass(N,p);	
  
  a = circle2d(N(1),s1,'n');
  a = [a; circle2d(N(2),1,'n')*s2];
  a = prdataset(a,genlab(N));
  
return
