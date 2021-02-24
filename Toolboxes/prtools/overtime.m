%OVERTIME Initialise or check PRTIME controlled execution time
%
% OVERTIME can be used to stop loops after a time set by PRTIME in the
% following way:
%
% starttime = overtime;     % initialise
% for i=1:n
%   ....                    % statements
%   if overtime(starttime)  % check time
%      prwarning(2,'execution stopped by PRTIME after %i iterations',i);
%      break;
%   end
% end
%
% SEE ALSO
% PRTIME

function out = overtime(starttime)

if nargin == 0
  out = clock; 
else
  runtime = etime(clock,starttime);
  out = runtime > prtime;
end


