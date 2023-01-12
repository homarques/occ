%GETCLASSI Get class index
%
%   INDEX = GETCLASSI(A,LABEL)
%
% INPUT
%   A     Dataset
%   LABEL Label used to label the class in A
%
% OUTPUT
%   INDEX Index of LABEL in the label list of A
%
% DESCRIPTION
% In some routines like SELDAT and ROC classes should be defined
% by their index in the label list of the dataset. This label list
% can be retrieved by GETLABLIST or CLASSNAMES. GETCLASSI can be used to
% find the index of the label directly.
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% DATASETS, SETLABELS, SETLABLIST GETLABLIST, CLASSNAMES

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function index = getclassi(a,label)
		
	if size(label,1) > 1
		n = size(label,1);
		index = zeros(1,n);
		for j=1:n
			index(j) = feval(mfilename,a,label(j,:));
		end
	else
	 index = strmatch(label,getlablist(a),'exact');
	end
	
return