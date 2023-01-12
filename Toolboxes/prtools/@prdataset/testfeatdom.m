%TESTFEATDOM Test feature domains
%
%	   [N,I,J] = TESTFEATDOM(A,K,M)
%
% The feature domains of the dataset A are tested. When given,
% the vector K should contain the indices of the features to
% be tested. Optionally, a vector M can be given which indicates which
% of the objects should be taken for testing.
%
% N = 0 if the dataset values are within the domains to be tested.
% N = 1 if somewhere a value is outside a domain. I and J return
%       the indices to the erroneous objects and features.
% 
%	TESTFEATDOM(A,K,M)
%
% Performs the test and prints an error message if a feature value
% outside a domain is encountered.

% $Id: testfeatdom.m,v 1.5 2009/07/17 22:15:13 duin Exp $

function [n,I,J] = testfeatdom(a,K,M)
		
	if isempty(a.featdom)
		return
	end
	
	% check the sizes of the arguments	
	[m,k] = size(a);
	if nargin < 2 || isempty(K), K = [1:k]; end
	if nargin < 3, M = [1:m]; end
	if max(K) > k || min(K) < 1
		error('Feature indices out of range')
	end
	if max(M) > m || min(M) < 1
		error('Object indices out of range')
	end

	% apply the checks on each of the features, using only the
	% requested objects from the dataset:
	I = []; J = [];
	for j = K
		domain = a.featdom{j};
		data = a.data(M,j);
		% find out which of the objects are outside the domain:
		II = [];
		if isempty(domain)
			;
		elseif ischar(domain)
			%This feature is discrete.
			II = check1(data,[1:size(domain,1)]);
		elseif size(domain,1) == 1
			%This feature is also discrete.
			II = check1(data,domain);
		elseif size(domain,2) == 2
			%This feature has a lower and upper bound.
			II = check2(data,domain);
		else
			error('Illegal feature domain format detected in feature %d',j)
		end
		if ~isempty(II)
			warning('Problem in feature %d',j);
		end
		I = [I M(II)];
		J = [J repmat(j,1,length(II))];
	end

	% if no objects are outside the domain, no alarm should be raised
	if isempty(I)
		if nargout == 1
			n = 0;
		end
	else
		if nargout == 1
			n = 1;
		else
			error([prnewline,'---- Feature value(s) out of range ----']);
		end
	end
return
	
function I = check1(data,domain)
	% check values for a discrete feature.
	I = [1:length(data)];
	J = [];
	for j=1:length(domain)
		J = [J find(data==domain(j) | isnan(data))'];
	end
	I(fliplr(sort(J))) = [];
return

function I = check2(data,domain)
	% check ranges (lower and upper bound) for a continuous feature
	[m,k] = size(domain);
	if m == 2 && all(domain(1,:) == domain(2,:))
		m = 1;
	end
	I = [1:length(data)];
	J = [];
	for j=1:m
		J = [J find((data >= domain(j,1)) & (data <= domain(j,2)) | isnan(data))'];
	end
	I(fliplr(sort(J))) = [];
return
