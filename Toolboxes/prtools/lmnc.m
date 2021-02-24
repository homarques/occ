%LMNC Levenberg-Marquardt trained feed-forward neural net classifier
% 
%  [W,HIST,UNITS] = LMNC (A,UNITS,ITER,W_INI,T)
%
% INPUT
%  A        Dataset
%  UNITS    Array indicating number of units in each hidden layer.
%           Default is a single hidden layer. Its size is the half of the 
%           number of objects in A divided by feature size plus class size
%           (roughly half of the number of parameters to be optimised) with
%           a maximum of 100;
%  ITER     Number of iterations to train (default: inf)
%  W_INI    Weight initialisation network mapping (default: [], meaning 
%           initialisation by Matlab's neural network toolbox). W_INI can
%           be the result of a previous training of LMNC, BPXNC or NEURC.
%  T        Tuning set (default: [], meaning use A)
%
% OUTPUT
%  W        Trained feed-forward neural network mapping
%  HIST     Progress report (see below)
%
% DESCRIPTION 
% A feed-forward neural network classifier with length(N) hidden layers with 
% N(I) units in layer I is computed for the dataset A. Training is stopped 
% after ITER epochs (at least 50) or if the iteration number exceeds twice 
% that of the best classification result. This is measured by the labeled 
% tuning set T. If no tuning set is supplied A is used. W_INI is used, if 
% given, as network initialisation. Use [] if the standard Matlab 
% initialisation is desired.
%
% An early stopping of the network optimisation is controlled by PRTIME.
%
% The entire training sequence is returned in HIST (number of epochs, 
% classification error on A, classification error on T, MSE on A, MSE on T,
% mean of squared weights).
%
% This routine escapes to KNNC if any class has less than 3 objects.
% 
% Uses the Mathworks' Neural Network toolbox.
%
% SEE ALSO (<a href="http://37steps.com/prtools">PRTools Guide</a>)
% MAPPINGS, DATASETS, BPXNC, NEURC, RNNC, RBNC, KNNC

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: lmnc.m,v 1.3 2007/06/15 09:58:30 duin Exp $

function [w,hist,units] = lmnc(varargin)

		[w,hist,units] = ffnc(mfilename,varargin{:});

return
