%GETPRIOR Get class prior probabilities of dataset
%
%   [PRIOR,LABLIST] = GETPRIOR(A,WARNING)
%
% INPUT
%   A        Dataset
%   WARNING  1: Generate warning if priors are not set and should be
%               computed from class frequencies (default)
%   WARNING  0: Suppress warning message
%
% OUTPUT
%   PRIOR    Class prior probabilities
%   LABLIST  Label list
%
% DESCRIPTION
% Returns the class prior probabilities as defined in the dataset A.
% In LABLIST the corresponding class labels are returned.
%
% Note that if these are not set (A.PRIOR = []), the class frequencies
% are measured and returned. Use ISEMPTY(A,'prior') to test whether 
% A.PRIOR = [].
%
% If A has soft labels, these are used to estimate the class frequencies. 
% If A has target labels, an error is returned since in that case, no 
% classes are defined.
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% DATASETS, SETPRIOR

% Copyright: R.P.W. Duin
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% $Id: getprior.m,v 1.8 2009/05/06 13:43:31 davidt Exp $

function [prior,lablist] = getprior(a,warning)
	
	if nargin < 2, warning = 1; end
	prior = a.prior;
	if (isempty(prior))
		switch a.labtype
			case 'crisp'
				prior = classsizes(a);
        if ~isempty(prior)
          prior = prior/sum(prior);
        end
				if length(prior) > 1 && warning
					st = dbstack;
					n = min(length(st),2);
					[cc,command] = fileparts(st(n).name);
					prwarning(1,[command ': No priors found in dataset, class frequencies are used instead'])
				end
			case 'soft'
				prior = mean(gettargets(a));
				prior = prior/sum(prior);
				if length(prior) > 1 && warning
					st = dbstack;
					n = min(length(st),2);
					[cc,command] = fileparts(st(n).name);
					prwarning(1,[command ': No priors found in dataset, class frequencies are used instead'])
				end
			case 'targets'
				prwarning(3,'No class priors defined for a dataset with the label type ''TARGETS''.')
				prior = 1;
		end
	end
	lablist = getlablist(a);
return;
