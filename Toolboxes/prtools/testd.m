%TESTD Find classification error of dataset applied to given classifier
%
%   [E,C] = TESTD(A,W)
%   [E,C] = TESTD(A*W)
%   [E,C] = TESTD(A,LABELS)
%    E    = A*W*TESTD
%
% INPUT
%   A    Dataset used for testing
%   W    Classifier
%   LAB  Estimated labels
%
% OUTPUT
%   E    Fraction of labeled objects in A that is erroneously classified or
%        that have different labels than LAB.
%   C    Vector with numbers of erroneously classified objects per class.
%        They are sorted according to A.LABLIST
%
% DESCRIPTION
% This routine performs a straightforward testing of the labeled objects
% in A by the classifier W. Unlabeled objects are neglected. Just a
% fraction of the erroneously classified objects is returned. Not all 
% classes have to be present in A and class priors are neglected. TESTD 
% thereby essentially differs from TESTC which tests the classifier instead
% of the dataset. Labels found for the individual objects by the classifier
% W may be retrieved by LABELD.
%
% The dataset A should have crisp labels. If needed they are converted to
% crisp first.
%
% SEE ALSO (<a href="http://37steps.com/prtools">PRTools Guide</a>)
% DATASETS, MAPPINGS, TESTC, LABELD

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function [error,class_errors] = testd(a,w)

	if nargin < 2, w = []; end
	if nargin < 1 || isempty(a)
		error = prmapping(mfilename,'fixed',{w});
		error = setname(error,'testd');
		class_errors = [];
	elseif isempty(w) % classification dataset expected
    [error,class_errors] = testd(a,a*labeld);
  elseif ismapping(w) && istrained(w)
		[error,class_errors] = testd(a*w);
  else               % estimated labels expected
    lab = w;
    if size(a,1) ~= size(lab,1)
      error('Label set expected with the same size as the number of objects')
    end
    a = setlabtype(a,'crisp');
		c = getsize(a,3);
		class_errors = zeros(1,c);
		n = 0;
		for j=1:c
			[~,J] = selclass(a,j);
			if numel(J) > 0
				class_errors(j) = nlabcmp(getlabels(a(J,:)),lab(J,:));
			end
			n = n+numel(J);
		end
		error = sum(class_errors)/n;
	end
	
return
			
			
