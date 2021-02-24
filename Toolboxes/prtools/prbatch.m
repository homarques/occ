%PRBATCH Compute loops for batch processing of large arrays
%
%   [N,L] = PRBATCH(M,K)
%
% If an MxK array has to be computed row by row, but the array
% manipulations do not fit into the memory defined by PRMEMORY than
% N gives the number of loop steps and the cell array L indexes the
% rows L{i} to be processed in step i. Intermediate arrays of length(L{i})
% rows and K columns will be smaller than PRMEMORY.

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com

function [n,L] = prbatch(m,k)

[n,rows,last] = prmem(m,k);
  
L = cell(1,n);
for i=1:n
  if i == n
    L{i}=(i-1)*rows+1:(i-1)*rows+last; 
  else
    L{i}=(i-1)*rows+1:i*rows; 
  end
end