%SETFEATSIZE Set featsize of datafile
%
%   A = SETFEATSIZE(A,FEATSIZE)
%
% INPUT
%   A        - Datafile
%   FEATSIZE - Desired feature size, 
%              Default: compute from first object in A
%
% OUTPUT
%   A       - Datafile
%
% DESCRIPTION
% If A is a dataset, its featsize is set. The featsize of a datafile
% is unclear as objects may have different sizes. For that reason
% the feature sizes of datafiles might better be set to 0, unless the
% objects are images of the same size.
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% DATAFILES

% Copyright: R.P.W. Duin
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function a = setfeatsize(a,featsize)

  if nargin < 2 || isempty(featsize)
    featsize = getfeatsize(a);
  end

  a.prdataset = setfeatsize(a.prdataset,featsize);
	
return
