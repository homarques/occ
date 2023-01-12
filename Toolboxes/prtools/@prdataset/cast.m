%CAST Dataset overload

function b = cast(a,type)

  if strcmp(type,'double')
    b = a.data;
  else
    error(['Dataset conversion to ' type ' is not possible'])
  end