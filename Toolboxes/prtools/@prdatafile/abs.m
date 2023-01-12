%ABS Datafile overload

function a = abs(a)

		
	isdatafile(a);
	a = a*filtm([],'abs');
	
return;
 