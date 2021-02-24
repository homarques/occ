%PRTVER Get PRTools version
%
%This routine is intended for internal use in PRTools only

function out = prtver

persistent PRTVERSION
if ~isempty (PRTVERSION)
	prtversion = PRTVERSION;
else % adapted for Octave
  prtoolsname = fileparts(which('fisherc'));
  prtfil = fullfile(fullfile(fileparts(prtoolsname),'prtools'),'Contents.m');
  s = textread(prtfil,'%s',20);
  n = strmatch('%',s);
  prtversion.Name = strjoin(s(n(1)+1:n(2)-1));
  prtversion.Version = char(s(n(2)+2));
  prtversion.Release = '';
  prtversion.Date = char(s(n(2)+3));
  prtversion = {prtversion datestr(now)};
%  prtoolsname = fileparts(which('fisherc'));
%  prtversion = {ver(prtoolsname) datestr(now)};
  PRTVERSION = prtversion;
end
if nargout == 0
  disp(prtversion{1})
else
  out = prtversion;
end
