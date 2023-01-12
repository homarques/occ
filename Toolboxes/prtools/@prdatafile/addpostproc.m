%ADDPOSTPROC Add mapppings in POSTPROC field of a datafile
%
%   A = ADDPOSTPROC(A,MAPPING)
%   A = ADDPOSTPROC(A)
%
% INPUT
%   A        - Datafile
%   POSTPROC - cell containing postprocessing mapping command
%
% OUTPUT
%   A       - Datafile
%
% DESCRIPTION
% Extends the set of mappings stored in A.POSTPROC.
% Existing mappings are extended sequentially: 
%      A.POSTPROC = A.POSTPROC * MAPPING
%
% Mappings in A.POSTPROC are stored only and executed just 
% after A is converted from a DATAFILE into a PRDATASET.
% The feature size of the datafile A is reset to the output
% size of PRMAPPING.
% The POSTPROC field  of A can be reset by SETPOSTPROC.
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% DATAFILES, SETPREPROC, SETPOSTPROC

% Copyright: R.P.W. Duin
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function a = addpostproc(a,mapp)
				
if nargin < 2
	;
elseif ismapping(mapp) || (iscell(mapp) && ismapping(mapp{1}))
  % dirty programming needed to avoid that this command has to be 
  % executed in the mapping directory
  if iscell(mapp)
    mapp = mapp{1};
  end
%  s_in = getfeatsize(a);
%	if size(mapp,1) ~= 0 && size(mapp,1) ~= prod(s_in) 
%		better not too check this as incoming objects may have different sizes
%		error('Input size postprocessing mapping does not match feature size datafile')
%	end
%	mapp = setsize_in(mapp,s_in);
	a.postproc = a.postproc*mapp;
  s = getsize_out(mapp);
	if isempty(s) | s == 0
    a = setfeatsize(a,0); % force recomputing output featsize
    s = getfeatsize(a);
  end % 	a.postproc = setsize_out(a.postproc,s);
  a.prdataset = setfeatsize(a.prdataset,s);
	%DXD This may be the correct place to set the output labels.
	%RD  This can only be done when they are defined, i.e. the mapping is
	%    trained.
  
	if istrained(mapp)
		 a.prdataset = setfeatsize(a.prdataset,getsize_out(mapp));
		 a.prdataset = setfeatlab(a.prdataset,getlab(mapp)); 
		 a.prdataset = setfeatsize(a.prdataset,getsize_out(mapp));
	end
else
	error('Mapping expected')
end

return
