%DATASETM Fixed mapping for conversion to dataset
%
%   B = DATASETM(A)
%   B = A*DATASETM
%
% INPUT
%   A    Double array, datafile, or other children of PRDATASET
%
% OUTPUT
%   B    DATASET
%
% DESCRIPTION
% This command is almost identical to B = PRDATASET(A), except that it
% supports the mapping type of construct: B = A*DATASETM. This may be
% especially useful to include the dataset conversion in a variable like
% for the processing definitions of a datafile.
%
% SEE ALSO (<a href="http://37steps.com/prtools">PRTools Guide</a>)
% DATASETS, DATAFILES, MAPPINGS, DATASET

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function b = datasetm(a)

if nargin < 1
	b = prmapping(mfilename,'fixed');
elseif isdataset(a)
	b = a;
elseif isdatafile(a)
	b = prdataset(a);
  if strcmp(gettype(a),'raw')
    b = setident(b,filenames(a,'full'),'filename');
  end
else
	b = prdataset(a);
end

	
