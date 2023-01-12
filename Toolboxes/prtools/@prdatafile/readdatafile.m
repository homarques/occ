%READDATAFILE Read one of the datafiles, choose for readdatafile 1 or 2
%
%    [B,NEXT,J] = READDATAFILE(A,N)
%
% INPUT     
%   A           Datafile
%   N           Number of the file to be read
%
% OUTPUT
%   B           Dataset stored in file N
%   NEXT        Number of next file to be read, 0 if done
%   J           Indices of objects in A
%
% DESCRIPTION
% A datafile points to a dataset stored in a series of files. This
% routine reads one of them, but is designed to read them all in a loop.
% A typical example is shown below, computing the overall mean per class.
% If the preprocessing field of A is set, the listed preprocessing is
% applied before returning.
% If the mappings field of A is set, the listed mappings are applied
% to B before returning.
%
% As the objects in A may be randomly distributed over the files, a 
% reordering is performed internally in this routine. Consequently,
% objects may be returned in a different order than stored in A.
%
% In case two datafiles have to be handled in the same process, or one
% datafiles twice, there is a problem with the persistent variables keeping
% track of the file. This routine can thereby call two identical copies 
% READDATAFILE1 or READDATAFILE2, controlled by the global variable
% NUMREADFILE (1 or 2). 
%
% EXAMPLE
% [m,k,c] = getsize(a);
% nobjects = classsizes(a);
% u = zeros(c,k);
% next = 1;
% while next > 0
%    [b,next] = readdatafile(a,next)
%    u = u + meancov(b) .* repmat(nobjects',1,k);
%    if next <= 0, break; end
% end
% u = u ./ repmat(classsizes(a)',1,k);
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% PRDATASET, DATAFILE

% Copyright: R.P.W. Duin
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function varargout = readdatafile(varargin)

  global NUMREADFILE

  if isempty(NUMREADFILE)
    NUMREADFILE = 1;
  end
  
  varargout = cell(1,nargout);
  if NUMREADFILE == 1
    [varargout{:}] = readdatafile1(varargin{:});
  else
    [varargout{:}] = readdatafile2(varargin{:});
  end
  
return
