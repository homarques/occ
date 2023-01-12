%SETPOSTPROC (Re)set POSTPROC field of a datafile
%
%   A = SETPOSTPROC(A,MAPPING)
%   A = SETPOSTPROC(A)
%
% INPUT
%   A        - Datafile
%   POSTPROC - cell containing postprocessing mapping command
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
				
s = getfeatsize(a);
k = prod(s);
if nargin < 2
	a.postproc = setsize_in(mapping([]),k); % Resset to unity mapping
	a.postproc = setsize_out(a.postproc,s); 
  a.prdataset = setfeatsize(a.prdataset,s);
elseif ismapping(mapp) || (iscell(mapp) && ismapping(mapp{1}))
  % dirty programming needed to avoid that this command has to be 
  % executed in the mapping directory
  if iscell(mapp)
    mapp = mapp{1};
  end
	if size(mapp,1) == 0
		mapp = setsize_in(mapp,k);
	end
	if size(mapp,1) ~= k
		error('Input size postprocessing mapping does not match feature size datafile')
  end
	a.postproc = mapp;
  s = getsize_out(mapp);
  if isempty(s) || s == 0
    s = getfeatsize(a);
  end
	if isfixed(a.postproc)
		a.postproc = setmapping_type(a.postproc,'trained');
	end
  a.prdataset = setfeatsize(a.prdataset,s);
else
	error('Mapping expected')
end

return
