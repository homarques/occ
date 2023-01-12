%PRKERNEL Kernel support routine
%
%   PRKERNEL(KERNEL)
%   D = PRKERNEL(A,B)
%   D = PRKERNEL(A,B,KERNEL)
%
% DESCRIPTION
% This routine serves as a support routine for STATSSVC.

function out = prkernel(a,b,kernel)

global PRKERNELMAPPING
if isempty(PRKERNELMAPPING)
  PRKERNELMAPPING = proxm([],'p',1);
end

if nargin == 1
  ismapping(a);
  isuntrained(a);
  PRKERNELMAPPING = a;
elseif nargin == 2
  out = a*(b*PRKERNELMAPPING);
else
  prkernel(kernel);
  out = prkernel(a,b);
end
  