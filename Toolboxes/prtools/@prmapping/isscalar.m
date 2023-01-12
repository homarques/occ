%ISSCALAR PRMAPPING overload to circumvent Octave bug

function flag = isscalar(w)

flag = prod(size(w)) == 1;
