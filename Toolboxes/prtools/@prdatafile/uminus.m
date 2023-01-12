%UMINUS Datafile overload

% $Id: uminus.m,v 1.3 2007/03/22 07:41:03 duin Exp $

function a = uminus(a)

		
	isdatafile(a);
	a = a*filtm([],'uminus');
	
return;
 