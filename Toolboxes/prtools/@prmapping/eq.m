%EQ Mapping overload

function c = eq(a,b)

  if ~isa(a,'prmapping') 
    c = eq(b,a); 
    return
  end

  c = dyadicm({a,b},'eq',[],size(a,2));

return

