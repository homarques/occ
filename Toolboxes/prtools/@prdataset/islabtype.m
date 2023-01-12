%ISLABTYPE Test dataset label type
%
%   N = ISLABTYPE(A,TYPE)
%   N = ISLABTYPE(A,TYPE1,TYPE2)
%   ISLABTYPE(A,TYPE)
% 	ISLABTYPE(A,TYPE1,TYPE2)
%
% INPUT
%   A      Dataset
%   TYPEx  Label type: 'crisp', 'soft', 'target'
%
% OUTPUT
%   N      1 if A has label type TYPE, or labeltype TYPE1 _or_ TYPE2;
%          0 otherwise
%
% DESCRIPTION
% If this routine is called without any output arguments an error is
% generated if the label type is not equal to one of the supplied ones.
% (i.e. it acts as an assertion).

% $Id: islabtype.m,v 1.4 2007/04/16 08:35:14 duin Exp $

function n = islabtype(a,varargin)

	n = 0;
	for j = 1:length(varargin)
		n = n || strcmp(a.labtype,varargin{j});
	end

	% Assertion?

	if (nargout == 0) && (n == 0)
		error([prnewline '---- Label type ''' a.labtype ''' of dataset is not supported ----'])
	end

return
