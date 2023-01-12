%GETFEATSIZE Get feature size of datafile
%
%	   FEATSIZE = GETFEATSIZE(A,N)
%    [FEATSIZE1,FEATSIZE2,FEATSIZE3] = GETFEATSIZE(A)
%
% Note that the feature size can be a scalar, or, in case of
% object images, an image size vector.

function [s1,s2,s3] = getfeatsize(a,n)

		
  s = getfeatsize(a.prdataset);
%   if isempty(s) || s == 0
% 		%we need to find feature size and it has not been set.
% 		%so, get first object
%     %disp('getfeatsize')
% 		b = readdatafile(a,1,0);
%     s = getfeatsize(b);
% 	end
  s1 = s;
  s2 = 1;
  s3 = 1;
  if nargin > 1
		if length(s1) < n
			s1 = 1;
		else
    	s1 = s1(n);
		end
  elseif nargout > 1
    s1 = s(1);
    if length(s) > 1
      s2 = s(2);
    end
    if length(s) > 2
      s3 = s(3);
    end
  end
