%GMM_DD Gaussian Mixture Model classifier
% 
%       W = GMM_DD(A,FRACREJ, N)
% 
% INPUT
%   A        Dataset
%   FRACREJ  Fraction of target objects rejected (default = 0.05)
%   N        Number of Gaussians (default = 1)
%
%

function W = gmm_dd(a, fracrej, n)

	% Take care of empty/not-defined arguments:
	if nargin < 3 || isempty(n), n = 1; end
	if nargin < 2 || isempty(fracrej), fracrej = 0.05; end
	if nargin < 1 || isempty(a) 
		% When no inputs are given, we are expected to return an empty
		% mapping:
		W = prmapping(mfilename,{fracrej, n});
		% And give a suitable name:
		W = setname(W,sprintf('Gaussian Mixture Model n:%d', n));
		return
	end

	if ~ismapping(fracrej)           %training
	    rng('default')
	    a = +target_class(a);     % only use the target class
	    [m,d] = size(a);
	    W.n = n;

	    % Fit a Gaussian mixture distribution to data
	    W.w = my_fitgmdist(a, n, 'Options', statset('Display','off','MaxIter',1000,'TolFun',1e-6), 'RegularizationValue', 0.01);

	    % computes outlier scores for training set
	    if(W.n > 1)
		W.scores = -min(mahal(W.w, a)')';
	    else
		W.scores = -mahal(W.w, +a);
	    end

	    % obtain the threshold
	    W.out = -W.scores;
	    W.threshold = dd_threshold(W.scores, fracrej);
	    W = prmapping(mfilename,'trained',W,str2mat('target','outlier'),d,2);
	    W = setname(W,sprintf('n:%d ', n));

	else %testing
	
	    % Unpack the mapping and dataset:
	    W = getdata(fracrej);
	    [m,d] = size(a);
	    if(W.n > 1)
		testScores = -min(mahal(W.w, +a)')';
	    else
		testScores = -mahal(W.w, +a);
	    end
		
	    % outlier scores for testing data
	    out = [testScores repmat(W.threshold,[m,1])];

	    % Fill in the data, keeping all other fields in the dataset intact:
	    W = setdat(a, out, fracrej);
	    W = setfeatdom(W,{[-inf 0;-inf 0] [-inf 0;-inf 0]});
	end
return


