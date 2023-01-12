%LE Mapping overload

function c = le(a,b)

  if ~isa(a,'prmapping') 
    c = gt(b,a); 
    return
  end

  c = dyadicm({a,b},'le',[],size(a,2));

return

