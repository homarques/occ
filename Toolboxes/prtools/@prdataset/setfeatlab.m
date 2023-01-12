%SETFEATLAB Reset feature labels of a dataset
%
%   A = SETFEATLAB(A,FEATLAB,K)
%
% INPUT
%   A        Dataset
%   FEATLAB  Feature labels
%   K        Vector of indices of feature labels to be reset  
%
% OUTPUT
%   A        Updated dataset
%
% DESCRIPTION
% Set or reset the feature labels of A. The feature labels FEATLAB of the 
% objects in A should be given as a column array of numbers (vector), or
% characters, or as a string array having as many rows as A has features. 
% If given, LENGTH(K) should be equal to LENGTH(FEATLAB).
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% DATASETS, PRDATASET, GETFEATLAB

% $Id: setfeatlab.m,v 1.7 2009/04/28 15:42:03 duin Exp $

function a = setfeatlab(a,featlab,K)

	[m,k,c] = getsize(a);
	if iscell(featlab)
		featlab = char(featlab);
	end
	if (nargin < 3)
		prwarning(5,'K not provided, all feature labels to be updated.')
		if (isempty(featlab))
			%featlab = [1:k]';
		elseif (size(featlab,1) < k)
			prwarning(1,['The label list should have at least ' num2str(k) ' elements.'])
			prwarning(1,'Empty feature labels inserted.')
			num = k - size(featlab,1);

			switch class(featlab)
			case 'double'
				featlab = [featlab; repmat(NaN,num,size(featlab,2))];
			case 'char'
				featlab = char(featlab,repmat(' ',num));
			end
		else
			;
		end
		if size(featlab,1) > k
			prwarning(1,'More labels are supplied than the data has features')
			prwarning(1,'Feature list is truncated');
			featlab = featlab(1:k,:);
		end
		a.featlab = featlab;
	else
		% Feature labels to be reset are stored in K.
		if (max(K) > k) || (min(K) < 1)
			error('Feature indices out of range.')
		end
		if (size(featlab,1) ~= length(K))
			error('Wrong number of feature indices given.')
		end
		if (~isa(featlab,class(a.featlab)))
			error('Format of new feature labels inconsistent with those of a dataset.')
		end
		switch class(featlab)
		case 'double'
			a.featlab(K) = featlab;
		case 'char' % needed to handle different string lengths
			af = char(a.featlab,featlab);
			af(K,:) = af(end-length(K)+1:end,:);
			a.featlab = af(1:end-length(K),:);
		end
	end

return;
