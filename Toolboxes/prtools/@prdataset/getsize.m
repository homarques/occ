%GETSIZE Dataset size and number of classes
%
%  [M,K,C] = GETSIZE(A,DIM)
%
% INPUT
%   A    Dataset
%   DIM  1,2 or 3 : the number of the output argument to be returned
%
% OUTPUT
%   M    Number of objects
%   K    Number of features
%   C    Number of classes
%
% DESCRIPTION
% Returns size of the dataset A and the number of classes. C is determined
% from the number of labels stored in A.LABLIST. If DIM = 1,2 or 3, just 
% one of these numbers is returned, e.g. C = GETSIZE(A,3).

% $Id: getsize.m,v 1.6 2009/02/19 12:31:52 duin Exp $

function [varargout] = getsize(a,dim)
		
	if nargin < 2
		s = [size(a) size(getlablist(a),1)];
	elseif dim <= 2
		s = size(a,dim);
	elseif dim == 3
		s = size(getlablist(a),1);
	else
		error('Illegal parameter value')
	end	

	if (nargout == 0)
		% Display the values on the screen.
		s+0
	elseif (nargout == 1)
		if (length(s) > 2), s = s(1:2); end
		varargout{1} = s;
	else								
		% Two or three output arguments
		v = ones(1,3);
		v(1:3) = s;
		for i=1:nargout
			varargout{i} = v(i);
		end
	end
return;

