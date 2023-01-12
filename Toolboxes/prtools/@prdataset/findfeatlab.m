%FINDFEATLAB Determine indices of features having specific labels
%
%   J = FINDFEATLAB(A,LABELS)
%
% If LABELS contains a single feature labels, J is a column vector of 
% indices to the features that have that label. If LABELS contains a set of
% feature labels, J is a cell array of indices, one for every label in
% LABELS. If no feature labels match, J is empty.
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% DATASETS, SETFEATLAB

function J = findfeatlab(a,labels)

if isa(labels,'char')
	labels = cellstr(labels);
end

n = length(labels);
J = zeros(n,1);
fl = getfeatlab(a);

if isa(labels,'double')
	if n == 1
		J = find(fl == labels);
	else
		J = cell(1,n);
		for i=1:n
			id = find(fl == labels(i));
			if ~isempty(id)
				J{i} = id;
			end
		end
	end
else
	if n == 1
		J = strmatch(labels{1},fl,'exact');
	else
		J = cell(1,n);
		for i=1:n
			id = strmatch(labels{i},fl,'exact');
			if ~isempty(id)
				J{i} = id;
			end
		end
	end
end

