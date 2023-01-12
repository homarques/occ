%MINUS Mapping overload

function c = minus(a,b)

  if ~isa(a,'prmapping') 
    c = plus(-b,a); 
    return
  end

  c = dyadicm({a,b},'minus',[],size(a,2));

return
