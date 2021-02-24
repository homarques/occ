%RNNC Random Neural Net classifier
% 
% 	W = RNNC(A,N,S)
% 
% INPUT
%   A   Input dataset
%   N   Number of neurons in the hidden layer
%   S   Standard deviation of weights in an input layer (default: 1)
%
% OUTPUT
%   W   Trained Random Neural Net classifier
%
% DESCRIPTION
% W is a feed-forward neural net with one hidden layer of N sigmoid neurons.
% The input layer rescales the input features to unit variance; the hidden
% layer has normally distributed weights and biases with zero mean and
% standard deviation S. The output layer is trained by the dataset A.
% Default N is number of objects * 0.2, but not more than 100.
% 
% If N and/or S is NaN they are optimised by REGOPTC.
%
% Uses the Mathworks' Neural Network toolbox.
%
% REFERENCES
% 1. W.F. Schmidt, M.A. Kraaijveld, and R.P.W. Duin, Feed forward neural
% networks with random weights, Proc. ICPR11, Volume II, 1992, 1-4. 
% 2. G.B. Huang, Q.Y. Zhu, C.K. Siew, Extreme learning machine: theory and
% applications, Neurocomputing, 70 (1), 2006, 489-501
%
% SEE ALSO (<a href="http://37steps.com/prtools">PRTools Guide</a>)
% MAPPINGS, DATASETS, LMNC, BPXNC, NEURC, RBNC

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: rnnc.m,v 1.4 2007/06/19 11:45:08 duin Exp $

function [w,n] = rnnc(a,n,s)

		
	checktoolbox('nnet');
	mapname = 'RandNeuralNet';

	if (nargin < 3)
		prwarning(3,'standard deviation of hidden layer weights not given, assuming 1');
		s = 1; 
	end
	if (nargin < 2)
		n = []; 
	end

	% No input arguments: return an untrained mapping.

	if (nargin < 1) || (isempty(a))
		w = prmapping('rnnc',{n,s});
		w = setname(w,mapname);
		return
	end

% 	islabtype(a,'crisp');
  if numel(classuse(a,1)) < 2 % at least 1 object per class, 2 classes
    prwarning(2,'training set too small: fall back to ONEC')
    w = onec(a);
    return
  end
	a = testdatasize(a);
	[m,k,c] = getsize(a);
  if c > 2, cout = c; else cout = 1; end
	
	if isempty(n)
		n = min(ceil(m/5),100);
    prwarning(3,['no number of hidden units specified, assuming ' num2str(n)]);
	end
	
  if isnan(n) || isnan(s) % optimise complexity parameter: number of neurons, st. dev.
		defs = {m/5,1};
		parmin_max = [1,min(m,100);0.01,10];
		w = regoptc(a,mfilename,{n,s},defs,[1,2],parmin_max,[],[0,1]);
		return
 	end

	% The hidden layer scales the input to unit variance, then applies a
	% random rotation and offset.
	
	w_hidden = scalem(a,'variance');
	w_hidden = w_hidden * cmapm(randn(n,k)*s,'rot');
	w_hidden = w_hidden * cmapm(randn(1,n)*s,'shift');

	% The output layer applies a FISHERC to the nonlinearly transformed output
	% of the hidden layer.

	w_output = w_hidden * sigm;
	w_output = fishers(a*w_output);
	
	% Construct the network and insert the weights.

  warning('off','NNET:Obsolete');
	transfer_fn = { 'logsig','logsig','logsig' };
  
  pp = prrmpath('nnperformance','mse');  % make sure we have the right mse
  finishup = onCleanup(@() addpath(pp)); % restore path afterwards
	net = newff(ones(k,1)*[0 1],[n cout],transfer_fn,'traingdx','learngdm','mse');
	%net = newff(ones(k,1)*[0 1],[n cout],transfer_fn,'trainlm','learngdm','mse');
  if ~isempty(pp), addpath(pp); end
	net.IW{1,1} = w_hidden.data.rot'; net.b{1,1} = w_hidden.data.offset';
  net.LW{2,1} = w_output.data.rot(:,1:cout)'; net.b{2,1} = w_output.data.offset(1:cout)';

	w = prmapping('neurc','trained',{net},getlabels(w_output),k,c);
	w = setname(w,mapname);
	w = setcost(w,a);

return

%FISHERS Trainable classifier: Fisher's Least Square Linear Discriminant
%        Simple multi-class version
% 
%   W = FISHERC(A)
% 
% INPUT
%   A  Dataset
%
% OUTPUT
%   W  Fisher's linear classifier 
%
% SEE ALSO (<a href="http://37steps.com/prtools">PRTools Guide</a>)
% MAPPINGS, DATASETS, TESTC, LDC, NMC, FISHERC

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function W = fishers(a)
		
 	[m,k,c] = getsize(a);
  lablist = getlablist(a);
  
	y = gettargets(a);
	if islabtype(a,'soft')
    % scale targets as in fnnc
    dom= scalem(y,'domain');
    y = y*dom;
    y = y*0.8 + 0.1; 
		%y = invsigm(y);  % better to give [0,1] targets full range
	end
	u = mean(a);    
	% Shift A to the origin. This is not significant, just increases accuracy.
	% A is extended by ones(m,1), a trick to incorporate a free weight in the 
	% hyperplane definition. 
	b = [+a-repmat(u,m,1), ones(m,1)]; 

	if (rank(b) <= k)
		% This causes Fisherc to be the Pseudo-Fisher Classifier
		prwarning(2,'The dimensionality is too large. Pseudo-Fisher is trained instead.');  
		v = prpinv(b)*y;                 
	else
		% Fisher is identical to the Min-Square-Error solution.		
		v = b\y;               
	end

	offset = v(k+1,:) - u*v(1:k,:); 	% Free weight. 
	W = affine(v(1:k,:),offset,a,lablist,k,c);
	% Normalize the weights for good posterior probabilities.
 	W = cnormc(W,a);									
	W = setname(W,'Fishers');

return;



	