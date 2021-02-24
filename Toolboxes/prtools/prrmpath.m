%PRRMPATH  Remove path conditionally
%
%     PATH = PRRMPATH(DIR,CMD)
%
% If DIR is not the containing directory of CMD, its full path is removed
% from the Matlab search path. The removed path is preserved in PATH to
% enable restoring later.

function p = prrmpath(dir1,dir2,cmd)

if nargin < 3,
  cmd  = dir2;
  dir2 = dir1;
  dir1 = '';
end

if exist(cmd) == 0
    p = '';
elseif isempty(dir1)
  p = fileparts(which(cmd));
  [dummy,d2] = fileparts(p);
  if ~strcmp(d2,dir2)
    rmpath(p);
  else
    p = '';
  end
else
  pp = what(cmd);
  [p,d2] = fileparts(pp(1).path);
  [dummy,d1] = fileparts(p);
  if ~(strcmp(d2,dir2) && (strcmp(d1,dir1) || isempty(d1)))
    rmpath(p);
  else
    p = '';
  end
end
