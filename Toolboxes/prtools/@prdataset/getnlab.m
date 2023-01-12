%GETNLAB Get numeric labels
%
%    [NLAB,LABLIST] = GETNLAB(A)
%
% The numeric labels of the dataset A are returned in NLAB.
% These are pointers to the list of labels LABLIST, so LABLIST(NLAB(i))
% is the label of object i. Note, however, that unlabeled objects or
% objects with a special label indication to be set by the user, may have
% numeric labels NLAB <= 0. Note also that for labels of type 'targets'
% the numeric labels NLAB are all set to 0. 
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% MULTI_LABELING

% Copyright: R.P.W. Duin
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% $Id: getnlab.m,v 1.5 2008/08/08 09:57:37 duin Exp $

function [nlab,lablist] = getnlab(a,flag)
				
	if nargin < 2, flag = 0; end
	if flag
		nlab = a.nlab;
	else
		n = curlablist(a);
		nlab = a.nlab(:,n);
	end
	if nargout > 1
		lablist = getlablist(a);
	end
return
