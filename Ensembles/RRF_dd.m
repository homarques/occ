%RRF_DD Dummy classifier for RRF method
% 
%       W = RRF_DD(A,FRACREJ,ranks)
%       W = A*RANDOM_DD([],FRACREJ,ranks)
%       W = A*RANDOM_DD(FRACREJ,ranks)
% 
% INPUT
%   A         m,n matrix of test data rankings where n = number of methods
%   combined
%   FRACREJ   Error on the target class (default = 0.1)
%
% OUTPUT
%   W         Random one-class classifier
%
% DESCRIPTION
% This is the trivial one-class classifier, randomly assigning labels
% and rejecting FRACREJ of the data objects. This procedure is just to
% show the basic setup of a Prtools classifier, and what is required
% to define a one-class classifier for dd_tools.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

%function W = random_dd(a,fracrej)
function W = RRF_dd(varargin)

argin = shiftargin(varargin,'scalar');
argin = setdefaults(argin,[],0.1);

if mapping_task(argin,'definition')
   W = define_mapping(argin,'untrained','Random cl.');

elseif mapping_task(argin,'training')

   [a,fracrej,ranks] = deal(argin{:});
	[m,k] = size(a);

	% train it:
	% Run combining rule on given rankings
    
    W.aggR = RRF(ranks')';
    
	%and save all useful data in a structure:
	W.threshold = fracrej;  % a threshold should *always* be defined
	W = prmapping(mfilename,'trained',W,str2mat('target','outlier'),k,2);
	W = setname(W,'Random one-class classifier');

elseif mapping_task(argin,'trained execution') %testing

   [a,fracrej] = deal(argin{:});
	% Unpack the mapping and dataset:
	W = getdata(fracrej);
	[m,k] = size(a); 

	% This classifier only contains the threshold, nothing more.

	% Output should consist of two numbers: the first indicating the
	% 'probability' that it belongs to the target, the second indicating
	% the 'probability' that it belongs to the outlier class. The latter
	% is often the constant threshold. Note that the object will be
	% classified to the class with the highest output. In the definition
	% above, the first column was for the target, the second column for
	% the outlier class:
	newout = [W.aggR repmat(W.threshold,m,1)];

	% Fill in the data, keeping all other fields in the dataset intact:
	W = setdat(a,newout,fracrej);
	W = setfeatdom(W,{[-inf 0;-inf 0] [0 inf;0 inf]});
else
   error('Illegal call to RRF_dd');
end
return


