%POWER Mapping overload

function c = power(a,b)

  if ~isa(a,'prmapping') 
    c = power(b,a); 
    return
  end

  c = dyadicm({a,b},'power',[],size(a,2));

return
