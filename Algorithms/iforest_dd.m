%IFOREST_DD Isolation Forest classifier
% 
%       W = IFOREST_DD(A,FRACREJ, NUMTREE, NUMSUB)
% 
%


function W = iforest_dd(a, fracrej, numTree, numSub)

% Take care of empty/not-defined arguments:
if nargin < 4 || isempty(numSub), numSub = 256; end
if nargin < 3 || isempty(numTree), numTree = 100; end
if nargin < 2 || isempty(fracrej), fracrej = 0.05; end
if nargin < 1 || isempty(a) 
	% When no inputs are given, we are expected to return an empty
	% mapping:
	W = prmapping(mfilename,{fracrej, numTree, numSub});
	% And give a suitable name:
	W = setname(W,sprintf('iForest numTree:%d numSub:%d', numTree, numSub));
	return
end

if ~ismapping(fracrej)           %training

    rng('default')
	a = +target_class(a);     % only use the target class
	[m,d] = size(a);
    
    % create and initialize the iForest java object
    W.forest = IsolationForest(a, numTree, numSub, d);
    % computes outlier scores for training set
    mass = IsolationEstimation(a, W.forest);
    W.scores = mean(mass, 2);
    % obtain the threshold
    W.out = -W.scores;
    W.threshold = dd_threshold(W.scores, fracrej);
    W = prmapping(mfilename,'trained',W,str2mat('target','outlier'),d,2);
	W = setname(W,sprintf('iForest numTree:%d numSub:%d', numTree, numSub));

else                               %testing

	% Unpack the mapping and dataset:
	W = getdata(fracrej);
    [m,d] = size(a);
    mass = IsolationEstimation(+a, W.forest);
	testScores = mean(mass, 2);

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
	W = setfeatdom(W,{[0 inf; 0 inf] [0 inf; 0 inf]});
end
return


