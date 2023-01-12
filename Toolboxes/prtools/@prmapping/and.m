%AND Mapping overload

function c = and(a,b)

  if ~isa(a,'prmapping') 
    c = and(b,a); 
    return
  end

  c = dyadicm({a,b},'and',[],size(a,2));

return
