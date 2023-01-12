%ADDPREPROC Add commands in the PREPROC field of a datafile
%
%   A = ADDPREPROC(A,PREPROC,PARS,OUTSIZE)
%
% INPUT
%   A       - Datafile
%   PREPROC - String with preprocessing command
%   PARS    - Cell array with parameters (default empty)
%   OUTSIZE - Output size of objects
%
% OUTPUT
%   A       - Datafile
%
% DESCRIPTION
% Extends the structure array of preprocessing commands, A.PREPROC( )
% with one element, having two fields:
% A.PREPROC(N).PREPROC = PREPROC
% A.PREPROC(N).PARS = PARS
%
% Preprocessing can only be defined for raw datafiles that do not contain
% datasets. It is an error to define preprocessing for a datafile that
% points to MAT files. In that case datasets are expected and preprocessing
% is superfluous.
%
% The first command in the PREPROC field should always be a file read
% command. The DATAFILE constructor stores by default IMREAD. Use
% SETPREPROC to clear the PREPROC field and replace it by another
% command.
%
% PRTools needs to know the size of the output objects. If not supplied in
% the call, it is found by processing the first object. This may take some
% time.
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>) 
% DATAFILES, SETPREPROC, ADDPOSTPROC, DATASETS

% Copyright: R.P.W. Duin
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function a = addpreproc(a,preproc,pars, outsize)
				
if nargin < 4, outsize = []; end
if nargin < 3, pars = {}; end
if ~iscell(pars), pars = {pars}; end

%outsize = 0; % RD added 19 nov 2012, better to make it always 0
%               20 nov 2012 not true, image size might be needed, how to solve?

if nargin < 2
	;
else
  if ~isempty(a.postproc)
    error('Preprocessing can only be defined if no postprocessing is set')
  end

	[n,k] = size(a.preproc);  % n > 1 in case of horzcat of datafiles
	if k == 1 && isempty(a.preproc(1).preproc)
		k = 0;
	end
	n = max(n,1); % n should be at least 1
	for j=1:n
		a.preproc(j,k+1).preproc = preproc;
		a.preproc(j,k+1).pars = pars;
	end
% 	we have decided not to set feature sizes for datafiles
%   unless explicitly demanded
%   if nargin < 4 || isempty(outsize)
% 	  b = readdatafile(a,1,0);
% 	  outsize = getfeatsize(b);
%   end
  if ~isempty(outsize)
    a.prdataset = setfeatsize(a.prdataset,outsize);
		k = prod(outsize);
		a.postproc = setsize(a.postproc,[k,k]);
  end
end

return
