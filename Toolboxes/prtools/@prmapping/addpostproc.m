%ADDPOSTPROC Add mapppings in POSTPROC field of a datafile
%
%   A = ADDPOSTPROC(A,MAPPING)
%   A = ADDPOSTPROC(A)
%
% INPUT
%   A        - Datafile
%   POSTPROC - Postprocessing mapping command
%
% OUTPUT
%   A       - Datafile
%
% DESCRIPTION
% Extends the set of mappings stored in A.POSTPROC.
% Existing mappings are extended sequentially: 
%
%      A.POSTPROC = A.POSTPROC * MAPPING
%
% Mappings in A.POSTPROC are stored only and executed just 
% after A is converted from a DATAFILE into a PRDATASET.
% The feature size of the datafile A is reset to the output
% size of PRMAPPING.
% The POSTPROC field of A can be reset by SETPOSTPROC.
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% DATAFILES, SETPREPROC, SETPOSTPROC

% Copyright: R.P.W. Duin
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function a = addpostproc(a,mapp)
			
    % this routine has to be placed in the mapping directory as mappings
    % are superior to datafiles. However, it is a typical datafile command
    % So we use the cell construct to hide its nature.
    
    a = addpostproc(a,{mapp});
    
return