%FIND_TARGET extract the indices of the target and outlier objects
%
%   [It,Io] = FIND_TARGET(A)
%   [It,Io] = FIND_TARGET(LAB)
%
% INPUT
%   A     One-class dataset
%   LAB   A label vector with 'target' and/or 'outlier'
%
% OUTPUT
%   It    Indices of target objects
%   Io    Indices of outlier objects
%
% DESCRIPTION
% Return the indices of the objects from dataset A which are labeled
% 'target' and 'outlier' in the index vectors It and Io respectively. A
% warning is given when no target objects can be found.
%
% It also works when no dataset but a label matrix LAB is given.
%
% SEE ALSO
% istarget, isocset, gendatoc, oc_set

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function [I1,I2] = find_target(a)

% first find the logical vector of target objects:
I = istarget(a);

% extract the indices:
I1 = find(I);

% if requested, also find the outliers:
if (nargout>1)
	I2 = find(~I);
end

return
