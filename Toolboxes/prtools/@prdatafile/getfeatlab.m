%GETFEATLAB Get feature labels of datafile
%
%   FEATLAB = GETFEATLAB(A,STRING)
%
% INPUT
%   A        Datafile
%   STRING   Indicate whether feature labels should be returned as strings
%            (if 'string' or 1), or not (default).
%
% OUTPUT
%   FEATLAB  Feature labels
%
% DESCRIPTION
% Returns the labels of the features of datafile A. If STRING equals 'string'
% or 1, the label list is converted to characters, which may be useful for
% display purposes and annotation of graphs.

function featlab = getfeatlab(a,s);

  if isempty(a.postproc)
    featlab = getfeatlab(a.prdataset);
  else
    featlab = getlabels(a.postproc);
    if isempty(featlab)
      featlab = getfeatlab(datasetm(seldat(a,[],[],1)));
    end
  end
    
	if (nargin > 1) && (string == 1 || strcmp(string,'string')) && (~ischar(featlab))
			featlab = num2str(featlab);
	end

 return