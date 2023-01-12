%PRTVER Get PRTools version
%
%This routine is intended for internal use in PRTools only

function out = prtver(toolbox)

if nargin < 1, toolbox = 'prtools'; end
persistent PRTVERSION
if isempty(PRTVERSION)
  PRTVERSION.(toolbox) = get_toolboxversion(toolbox);
end
if isfield(PRTVERSION,toolbox)
  toolboxversion = PRTVERSION.(toolbox);
else
  toolboxversion = get_toolboxversion(toolbox);
  PRTVERSION.(toolbox) = toolboxversion;
end

if nargout == 0
  disp(toolboxversion{1})
else
  out = toolboxversion;
end

function toolboxversion = get_toolboxversion(toolbox)
% adapted for Octave
  prtfil = which(fullfile(toolbox,'Contents.m'));
  s = textread(prtfil,'%s',20);
  n = strmatch('%',s);
  toolboxversion.Name = strjoin(s(n(1)+1:n(2)-1));
  toolboxversion.Version = char(s(n(2)+2));
  toolboxversion.Release = '';
  toolboxversion.Date = char(s(n(2)+3));
  toolboxversion = {toolboxversion datestr(now)};
return

