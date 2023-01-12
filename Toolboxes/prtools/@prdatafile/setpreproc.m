%SETPREPROC Set the PREPROC field of a datafile
%
%   A = SETPREPROC(A,PREPROC,PARS)
%   A = SETPREPROC(A,PSTRUCT)
%   A = SETPREPROC(A)
%
% INPUT
%   A       - Datafile
%   PREPROC - String with preprocessing command
%   PARS    - Cell array with parameters (default empty)
%   PSTRUCT - Structure array with a set of preprocessing commands
%
% OUTPUT
%   A       - Datafile
%
% DESCRIPTION
% Resets the structure array of preprocessing commands in A.PREPROC.
% A.PREPROC(N).PREPROC = PREPROC
% A.PREPROC(N).PARS = PARS
%
% A call without PREPROC and PARS clears A.PREPROC.
%
% Preprocessing can only be defined for raw datafiles that do not contain
% datasets. It is an error to define preprocessing for a datafile that
% points to MAT files. In that case datasets are expected and preprocessing
% is superfluous. All preprocessing commands are executed just before a 
% DATAFILE is converted into a PRDATASET.
%
% The first command in the PREPROC field should always be a file read
% command. The DATAFILE constructor stores by default IMREAD. It is removed
% by SETPREPROC. Be sure to start a new series of preprocessing commands by
% a command to read files. The first parameter of this commands should be
% the filename.
%
% Additional preprocessing commands may be stored by ADDPREPROCC.
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>) 
% DATAFILES, ADDPREPROC, DATASETS

% Copyright: R.P.W. Duin
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function a = setpreproc(a,preproc,pars)
				
  if ~isempty(a.postproc)
    error('Preprocessing can only be defined if no postprocessing is set')
  end

	if nargin < 2
		a.preproc.preproc = [];
		a.preproc.pars = {};
	elseif nargin < 3 && isstruct(preproc)
 		if ~(isfield(preproc,'preproc') && isfield(preproc,'pars'))
    	error('Structure for setting preprocessing should contain ''preproc'' and ''pars'' fields')
  	end
  	a.preproc = preproc;
	elseif nargin < 3
  	a.preproc.preproc = preproc;
  	a.preproc.pars = {};
	else
		a.preproc.preproc = preproc;
  	if ~iscell(pars)
    	pars = {pars};
  	end
		a.preproc.pars = pars;
	end
	b = readdatafile(a,1,0); % for various reasons it is needed to have feature size
	a.prdataset = setfeatsize(a.prdataset,getfeatsize(b)); % we use the first object.

return
