%ISFINITE Datafile overload

function n = isfinite(a)

	  
	a = a*filtm([],'isfinite');
	n = +a;

