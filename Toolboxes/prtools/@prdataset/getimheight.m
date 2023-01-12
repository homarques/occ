%GETIMHEIGHT Get featsize, function oudated
%
% IMHEIGHT = GETIMHEIGHT(A)
%
% Returns feature size and prints warning.
% This routine is outdated, it should be replaced by GETFEATSIZE or
% GETOBJSIZE. It is assumed to be GETFEATSIZE for the moment.

% $Id: getimheight.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function imheight = getimheight(a)

	warning('GETIMHEIGHT is outdated, replace it by ''GETFEATSIZE'' or ''GETOBJSIZE''.')
	imheight = getfeatsize(a);
	if (length(imheight) == 1)
		imheight = 0;
	else
		imheight = imheight(2);
	end
return;
