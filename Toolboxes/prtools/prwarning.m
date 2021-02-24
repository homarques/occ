%PRWARNING Show PRTools warning
%
%  PRWARNING(LEVEL,FORMAT,...) 
%
% Shows the message (given as FORMAT and a variable number of arguments),
% if the current PRWARNING level is >= LEVEL.
%
%  PRWARNING(LEVEL) - Set the current PRWARNING level
%
% Set the PRWARNING level to LEVEL. The default level is 2.
% The levels currently in use are:
% 0  no warnings
% 1  severe warnings, useful for users as results might be wrong or
%    need a different interpretation than might be expected.
% 2  warnings for the designer, e.g. when other procedures had to be
%    used than demanded, e.g. due sample size problems or limited 
%    computer time.
% 3  light warnings, primarily useful for programmers.
%
% - PRWARNING OFF - Same as PRWARNING(0)
% - PRWARNING ON - Same as PRWARNING(1)
% - PRWARNING - Same as PRWARNING(1)

% Copyright: D. de Ridder, R.P.W. Duin, r.p.w.duin@37steps.com
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% $Id: prwarning.m,v 1.5 2007/11/30 16:29:49 duin Exp $

function lev = prwarning (level, varargin)

  persistent PRWARNINGGLOBAL;

  if (isempty (PRWARNINGGLOBAL))
    PRWARNINGGLOBAL = 2;
  end

  if (nargin == 0) && (nargout == 0) % Set warning level to default
    PRWARNINGGLOBAL = 1;
  elseif (nargin == 1)        % Set warning level
    if ischar(level) && strcmp(level,'off')
      level = 0;
    elseif ischar(level) && strcmp(level,'on')
      level = 1;
    elseif ischar(level) % wrong call, no level supplied
      warning(level);   % print standard warning
      level = PRWARNINGGLOBAL; % do not change PRWARNINGGLOBAL
    end
    PRWARNINGGLOBAL = level;
  elseif nargin > 0
    if (level <= PRWARNINGGLOBAL)
      [st,i] = dbstack;   % Find and display calling function (if any)
      if (length(st) > 1)
        caller = st(2).name;
        [paths,name] = fileparts(caller);
        if strcmp(name,'cleandset'), 
          caller = st(3).name;
        end
        [paths,name] = fileparts(caller);          
        fprintf (2, 'PR_Warning: %s: ', upper(name));
      end;
      fprintf (2, varargin{:});
      fprintf (2, '\n');
    end
  end

  if nargout > 0
    lev = PRWARNINGGLOBAL;
  end
  return
