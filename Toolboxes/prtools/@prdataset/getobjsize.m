%GETOBJSIZE Get object size
%
%    OBJSIZE = GETOBJSIZE(A,N)
%    [OBJSIZE1,OBJSIZE2,OBJSIZE3] = GETOBJSIZE(A)
%
% Note that the object size can be a scalar, or, in case of feature images,
% an image size vector.

% $Id: getobjsize.m,v 1.3 2007/01/16 16:08:28 duin Exp $

function [s1,s2,s3] = getobjsize(a,n)

		
	s1 = a.objsize;
  s2 = 1;
  s3 = 1;
  if nargin > 1
    s1 = s1(n);
  elseif nargout > 1
    if length(s1) > 1
      s2 = s1(2);
    end
    if length(s1) > 2
      s3 = s1(3);
    end
    s1 = s1(1);
  end