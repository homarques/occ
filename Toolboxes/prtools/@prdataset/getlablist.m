%GETLABLIST Get label list of dataset
%
%   LABLIST = GETLABLIST(A,STRING)
%
% Returns the label list of a dataset A.
% If STRING equals 'string' the label list is converted to characters,
% which may be useful for display purposes and annotation of graphs.
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% MULTI_LABELING

% Copyright: R.P.W. Duin
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% $Id: getlablist.m,v 1.4 2006/09/26 13:07:34 duin Exp $

function lablist = getlablist(a,string)
	
	if iscell(a.lablist)
		n = a.lablist{end,2};
		lablist = a.lablist{n,1};
    
	else
		lablist = a.lablist;
  end
	
  if nargin > 1
    if ischar(string) && strcmp(string,'string')
      string = 1;
    end
    if string == 1 && iscell(lablist)
      lablist = char(lablist);
    elseif string == 1  && (~ischar(lablist))
      lablist = num2str(lablist);
    end
	end
	
return;
