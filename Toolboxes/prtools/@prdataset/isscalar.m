%ISSCALAR PRDATASET overload to circumvent Octave bug

function flag = isscalar(a)

flag = isscalar(a.data); 