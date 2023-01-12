%GETFEATSIZE Get feature size
%
%	   FEATSIZE = GETFEATSIZE(A,N)
%    [FEATSIZE1,FEATSIZE2,FEATSIZE3] = GETFEATSIZE(A)
%
% Note that the feature size can be a scalar, or, in case of
% object images, an image size vector.

% $Id: getfeatsize.m,v 1.7 2008/11/28 15:45:47 duin Exp $

function [s1,s2,s3] = getfeatsize(a,n)

		
	s1 = a.featsize;
	
	% if indicated in the user_field, treat features as a 1D signal
	if length(s1) == 1 && isfield(a.user,'signal'), s1 = [1 s1 1]; end
	% let images always have a single band
	if length(s1) == 2, s1 = [s1 1]; end
	
	%if length(s1) == 1
	%	s1 = [s1 1 1];
	%end
	%if length(s1) == 2
	%	s1 = [s1 1];
	%end
  s2 = 1;
  s3 = 1;
  if nargin > 1
		if length(s1) < n
			s1 = 1;
		else
    	s1 = s1(n);
		end
  elseif nargout > 1
    if length(s1) > 1
      s2 = s1(2);
    end
    if length(s1) > 2
      s3 = s1(3);
    end
    s1 = s1(1);
  end
