%RANDOM_DD Random one-class classifier
% 
%       W = RANDOM_DD(A,FRACREJ)
% 
% This is the trivial one-class classifier, randomly assigning labels
% and rejecting FRACREJ of the data objects. This procedure is just to
% show the basic setup of a Prtools classifier, and what is required
% to define a one-class classifier for dd_tools.

% Copyright Lorne Swersky, swersky@ualberta.ca
% Faculty of Computing Science, University of Alberta


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

    % create and initialize the iForest java object
    W.w = my_fitgmdist(a, n, 'Options',statset('Display','off','MaxIter',1000,'TolFun',1e-6), 'RegularizationValue', 0.01);
    % computes outlier scores for training set
    W.n = n;
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

else                               %testing

	% Unpack the mapping and dataset:
	W = getdata(fracrej);
	[m,d] = size(a);
	if(W.n > 1)
		testScores = -min(mahal(W.w, +a)')';
	else
		testScores = -mahal(W.w, +a);
	end
	% Output should consist of two numbers: the first indicating the
	% 'probability' that it belongs to the target, the second indicating
	% the 'probability' that it belongs to the outlier class. The latter
	% is often the constant threshold. Note that the object will be
	% classified to the class with the highest output. In the definition
	% above, the first column was for the target, the second column for
	% the outlier class:
	out = [testScores repmat(W.threshold,[m,1])];

	% Fill in the data, keeping all other fields in the dataset intact:
	W = setdat(a, out,fracrej);
	W = setfeatdom(W,{[-inf 0;-inf 0] [-inf 0;-inf 0]});
end
return


