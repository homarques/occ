%SETNLAB Set label indices (numeric labels) directly
%
%    A = SETNLAB(A,NLAB,J)
%
% Resets the values of A.NLAB(J,N) to NLAB, in which N points
% to the current label list for A. Note that NLAB gives indices
% to the labels defined in this label list. Values of NLAB <= 0 are
% stored but treated as missing labels. For crisp labels only.
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% MULTI_LABELING

% Copyright: R.P.W. Duin
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% $Id: setnlab.m,v 1.8 2008/10/30 14:13:46 duin Exp $

function a = setnlab(a,nlab,J)
				
	lablista = getlablist(a);
	if max(nlab) > size(lablista,1)
		error('Values of NLAB larger than number of labels in LABLIST')
	end
	m = prod(a.objsize);
	n = curlablist(a);
  if isempty(a.nlab)
    a.nlab = nlab;
  elseif nargin < 3
		if length(nlab) == 1
			nlab = repmat(nlab,m,1);
		elseif length(nlab) ~= m
			error('Incorrect number of elements in NLAB')
		end
		a.nlab(:,n) = nlab;
	else
		if length(nlab) == 1
			nlab = repmat(nlab,length(J),1);
		elseif length(nlab) ~= length(J)
			error('Inconsistent number of elements in NLAB')
		elseif max(J) > m
			error('Object indices out of range')
		end
		a.nlab(J,n) = nlab;
	end
return
