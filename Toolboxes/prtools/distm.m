%DISTM Fixed mapping for computing a square Euclidean distance matrix
% 
%   D = DISTM(A,B)
%   D = DISTM(A);
%   D = A*DISTM
% 
% INPUT
%   A,B   Datasets or matrices; B is optional, default B = A 
%
% OUTPUT
%   D     Square Euclidean distance dataset or matrix
%
% DESCRIPTION  
% Computation of the distance matrix D between two sets A and B. 
% If A has M objects and B has N objects, then D is [M x N]. If A and B are
% datasets, then D is a dataset as well with the labels defined by the
% labels of A and the feature labels defined by the labels of B. 
%
% Unlabeled objects in B are neglected, unless B is entirely unlabeled.
% If A is not a dataset, but a matrix of doubles then D is also not a
% dataset, but a set of doubles.
%
% NOTE (1)
% DISTM was in older Matlab versions for large datasets considerable faster
% than PDIST2. Now it uses internally PDIST2.
%
% NOTE (2)
% The default distance meansure used by DISTM is the square of the
% Euclidean distance. This can be changed by calling DISTYPE which sets a
% global used by DISTM.
% 
% NOTE (3)
% DISTM(A,B) is equivalent to A*PROXM(B,'d',2)).
% 
% SEE ALSO (<a href="http://37steps.com/prtools">PRTools Guide</a>)
% DATASETS, PROXM, DISTYPE, PDIST2

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% $Id: distm.m,v 1.8 2009/11/27 08:53:00 duin Exp $

function D = distm(A,B)

  global DISTANCETYPE
  if isempty(DISTANCETYPE)
    DISTANCETYPE = {'SquaredEuclid'};
  end
		
	if nargin == 0
		D = prmapping(mfilename,'fixed');
    D = setuser(D,'pe_mapping','type'); % can handle pe_mappings
		return
	end
	
	if nargin < 2
		B = A;
	end
	%B = cdats(B,1);  % ???? why just labeled objects in B ?????
	
	[ma,ka] = size(A);
	[mb,kb] = size(B);
	
% 	if (ka ~= kb)
% 		error('Feature sizes should be equal')
% 	end
	
	if isdatafile(A)
	
		D = zeros(ma,mb);
		next = 1;
		while next > 0
			[a,next,J] = readdatafile1(A,next);
			D(J,:) = +distm(a,B);
		end
		
	elseif isdatafile(B)

		D = zeros(ma,mb);
		next = 1;
		while next > 0  % we need another version of readdatafile here, as due
			[b,next,J] = readdatafile2(B,next); % to persistent variables double
			D(:,J) = +distm(A,b); % looping can not be handled correctly
		end
		
	else % A and B are not datafiles
    
    % here the original code is replaced by a call to pdist2
    
    if strcmp(DISTANCETYPE,'SquaredEuclid')
      D = pdist2(+A,+B).^2;
    else
      type = lower(DISTANCETYPE{1});
      if numel(DISTANCETYPE) > 1
        D = pdist2(+A,+B,type,DISTANCETYPE{2:end});
      else
        D = pdist2(+A,+B,type);
      end
    end
	
% 		% The order of operations below is good for the accuracy.
%         testdatasize(ma*mb); % check memory sizes
% 		D = ones(ma,1)*sum(B'.*B',1);
% 		D = D + sum(A.*A,2)*ones(1,mb);
% 		D = D - 2 .* (+A)*(+B)';
% 
% 		J = find(D<0);                  % Check for a numerical inaccuracy. 
% 		D(J) = zeros(size(J));          % D should be nonnegative.
	
		if ((nargin < 2) && (ma == mb)) % take care of symmetric distance matrix
			D = (D + D')/2;              
			D([1:ma+1:ma*ma]) = zeros(1,ma);
		end
		
	end
	
	if isa(A,'prdataset')   % set object and feature labels
		if isa(B,'prdataset')
			D = setdata(A,D,getlab(B));
		else
			D = setdata(A,D);
		end
	end
		
return
