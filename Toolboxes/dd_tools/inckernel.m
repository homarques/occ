%INCKERNEL Kernel definition for incsvdd/incsvc
%
%              K = INCKERNEL(PAR,I,J);
%
% INPUT
%   PAR       structure defining kernel type and parameters
%   I,J       index (i,j) in kernel
%
% OUTPUT
%   K         kernel value K(i,j)
%
% DESCRIPTION
% Computation of the kernel function for the incremental SVDD. It is
% assumed that there is a global variable X_incremental, containing the
% objects. This is to avoid unnecessary overhead for very large
% datasets. Therefore we will also not use the 'standard' ways to comute
% the kernel (i.e. proxm).
%
% For the definition of the kernel types, see dd_kernel.
%
% The index vectors I and J indicate between which objects in
% X_incremental the kernel should be computed.
%
% SEE ALSO
% dd_kernel, incsvdd, dd_proxm, Wstartup, Wadd

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function K = inckernel(par,I,J);

global X_incremental;
if isempty(X_incremental)
  error('No data matrix X_incremental defined');
end
if isdataset(X_incremental);
  error('Please make X_incremental a normal matlab array');
end

A = X_incremental(I,:);
B = X_incremental(J,:);

K = dd_kernel(A,B,par.type,par.s);

return
