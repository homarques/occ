%GT Mapping overload

function c = gt(a,b)

  if ~isa(a,'prmapping') 
    c = le(b,a); 
    return
  end

  c = dyadicm({a,b},'gt',[],size(a,2));

return

