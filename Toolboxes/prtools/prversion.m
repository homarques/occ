%PRVERSION PRTools version number
%
%		NEW = PRVERSION(TOOLBOX)
%
% DESCRIPTION
% Checks whether a more recent version of TOOLBOX is available on the web.

% $Id: prversion.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function newversion = prversion(toolbox)

if nargin < 1, toolbox = 'prtools'; end

	signature = prtver(lower(toolbox));
	str = signature{1}.Version;
  myversion = str2version(str);
	if nargout == 0
		disp([prnewline '   ' toolbox ' my  version ' str])
  end
  location = ['http://prtools.tudelft.nl/files/' toolbox '_version.txt'];
  if verLessThan('matlab','8.0')
    s = ''; % Cannot read if server is down
  else
    [s,status] = urlread(location,'TimeOut',5);
  end
  if ~status || isempty(s)
    if nargout == 0
      disp('web version not available')
    else
      webversion = [];
    end
  else
    s = [s ' '];                % make sure there is a space
    s = strrep(s,newline,' '); % replace newline by space
    nspace = strfind(s,' ');
    str = s(nspace(1)+1:nspace(2)-1);
    webversion = str2version(str);
    date = s(nspace(2)+1:nspace(3)-1);
  end
  if ~isempty(webversion)
    if nargout == 0
      disp(['   ' toolbox ' web version ' str prnewline])
    else
      newversion = webversion > myversion;
    end
  else
    newversion = false;
  end

function version = str2version(str)
n = strfind(str,'.');
if isempty(n)
  version = str2double(str);
elseif length(n) == 1
  version = str2double(str(1:n-1)) + str2double(str(n+1:end))/100;
else
  version = str2double(str(1:n(1)-1)) + str2double(str(n(1)+1:n(2)-1))/100 + str2double(str(n(2)+1:end))/10000;
end
return;
