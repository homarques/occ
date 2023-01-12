%SETPOSTPROC (Re)set POSTPROC field of a datafile
%
%   A = SETPOSTPROC(A,MAPPING)
%   A = SETPOSTPROC(A)
%
% INPUT
%   A        - Datafile
%   POSTPROC - Postprocessing mapping command
%
% OUTPUT
%   A       - Datafile
%
% DESCRIPTION
% Sets the mappings stored in A.POSTPROC. The size of the datafile
% A is set to the output size of PRMAPPING.
% A call without MAPPING clears A.POSTPROC. The size of the datafile
% A is reset to undefined (0).
%
% The mappings in A.POSTPROC may be extended by ADDPOSTPROC.
%
% Mappings in A.POSTPROC are stored only and executed just 
% after A is converted from a DATAFILE into a PRDATASET.
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% DATAFILES, SETPREPROC, ADDPOSTPROC.

% Copyright: R.P.W. Duin
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function a = setpostproc(a,mapp)
		    
    % this routine has to be placed in the mapping directory as mappings
    % are superior to datafiles. However, it is a typical datafile command
    % So we use the cell construct to hide its nature.
    
    a = setpostproc(a,{mapp});
		
return
