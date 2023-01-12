%OR Mapping overload

function c = or(a,b)

  if ~isa(a,'prmapping') 
    c = or(b,a); 
    return
  end

  c = dyadicm({a,b},'or',[],size(a,2));

return
