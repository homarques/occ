%DOUBLE Mapping / double conversion
%
%	D = DOUBLE(W)
%
% Obsolete: conversion is not possible anymore, use +W to extract data.

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: double.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function d = double(w)

		error('Mappings cannot be converted to doubles, use the + operator to extract data.')

return
