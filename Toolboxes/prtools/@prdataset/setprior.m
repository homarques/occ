%SETPRIOR Reset class prior probabilities of dataset
%
%   A = SETPRIOR(A,PROB,LABLIST)
%
% INPUT
%   A        Dataset
%   PROB     Prior probabilities to be set
%   LABLIST  Label list (optional)
%
% OUTPUT
%   A        Updated dataset
%
% DESCRIPTION
% Resets the class prior probabilities of the dataset A to PROB. PROB should
% be a vector of the length equal to the number of classes in A. In LABLIST,
% the corresponding class labels may be supplied. LABLIST may have only
% class names of the existing classes in A. Reset class names first by 
% SETLABLIST if necessary.
%
% If LABLIST is not given, the order defined by the existing LABLIST for A
% (determined by [NLAB,LABLIST] = renumlab(LABELS)) is used.
%
% PROB = 0 makes all C classes equally probable: 1/C.
% PROB = [] is interpreted as using the existing class frequencies in A as
% prior probabilities. Note that these prior probabilities change, if the
% number of elements in A is changed, or its labeling.
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% PRDATASET, GETPRIOR, ISEMPTY

% $Id: setprior.m,v 1.7 2009/05/06 13:43:31 davidt Exp $

function a = setprior(a,prior,lablist)

	if (strcmp(a.labtype,'targets'))
		prwarning(3,'No priors defined for a dataset with the label type of ''TARGETS''.')
		priora = 1;
	end

	lablista = getlablist(a);
	
	c = size(lablista,1);
	if (~isempty(prior))
		if (prior == 0)
			priora = ones(1,c)/c;
		elseif (length(prior) ~= c)
			c
			error('Number of prior probabilities should be equal to number of classes.')
		else
			%priora = prior/sum(prior); % dont do this !!!!! 
			priora = prior;
		end
	else
		priora = [];
	end
	
	if (nargin > 2) && (~isempty(lablist))
		[nl1,nl2,labl] = renumlab(lablista,lablist);
		if (max(nl2) > c)
			error('Label list does not correspond to the set of labels.')
		end
		priora(nl2) = a.prior;
	end
	
	if ~isempty(priora)
  	priora = priora(:)';
	end
	
	a.prior = priora;
	if iscell(a.lablist)
		n = a.lablist{end,2};
		a.lablist{n,2} = a.prior;
	end
	
return
