%INVSIG The inverse sigmoid of a dataset

% $Id: invsig.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function a = invsig(a)

		
	a = log(a+realmin) - log(1-a+realmin);
	
	return

