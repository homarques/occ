%GETVERSION Get PRTools version and date of dataset
%
%   [VERSION,DATE] = GETVERSION(A)
%
% INPUT
%   A        Dataset
% 
% OUTPUT
%   VERSION  PRTools version with which A was created
%   DATE     Date of creation of A

% $Id: getversion.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function [version,date] = getversion(a)

	version = a.version{1};
	date    = a.version{2};

return

