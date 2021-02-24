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


function W = gloshdd(a, fracrej, minPts, minClSize)

% Take care of empty/not-defined arguments:
if nargin < 3 || isempty(minPts), minPts = 1; end
if nargin < 4 || isempty(minClSize), minClSize = minPts; end
if nargin < 2 || isempty(fracrej), fracrej = 0.05; end
if nargin < 1 || isempty(a) 
	% When no inputs are given, we are expected to return an empty
	% mapping:
	W = prmapping(mfilename,{fracrej, minPts, minClSize});
	% And give a suitable name:
	W = setname(W,sprintf('GLOSHDD minPts:%d minClSize:%d', minPts, minClSize));
	return
end

import ca.ualberta.cs.hdbscanstar.*

if ~ismapping(fracrej)           %training

	a = +target_class(a);     % only use the target class
	[m,d] = size(a);
    
    if (minPts > m)
        error(['Minimum number of points for reachability is greater than number of training samples! (max=',num2str(m),')']);
    end
    
    % create and initialize the GLOSHDD java object
    W.gloshModel = ApproxGLOSHDD(a, minPts, minClSize);
    % computes outlier scores for training set
    W.scores = W.gloshModel.trainGLOSHDD();
    W.out = W.gloshModel.trainGLOSHDD();
    % obtain the threshold
    W.threshold = dd_threshold(W.scores,1-fracrej);
    W = prmapping(mfilename,'trained',W,str2mat('target','outlier'),d,2);
	W = setname(W,sprintf('GLOSHDD minPts:%d minClSize:%d', minPts, minClSize));

else                               %testing

	% Unpack the mapping and dataset:
	W = getdata(fracrej);
    [m,d] = size(a);
	testScores = W.gloshModel.computeScores(+a);

	% Output should consist of two numbers: the first indicating the
	% 'probability' that it belongs to the target, the second indicating
	% the 'probability' that it belongs to the outlier class. The latter
	% is often the constant threshold. Note that the object will be
	% classified to the class with the highest output. In the definition
	% above, the first column was for the target, the second column for
	% the outlier class:
	out = [testScores repmat(W.threshold,[m,1])];

	% Fill in the data, keeping all other fields in the dataset intact:
	W = setdat(a,1-out,fracrej);
	W = setfeatdom(W,{[0 1;0 1] [0 1;0 1]});
end
return


