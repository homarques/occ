%ISNAN Datafile overload

function n = isnan(a)

	  
	a = a*filtm([],'isnan');
	n = +a;

