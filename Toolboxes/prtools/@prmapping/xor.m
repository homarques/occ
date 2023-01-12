%XOR Mapping overload

function c = xor(a,b)

  if ~isa(a,'prmapping') 
    c = xor(b,a); 
    return
  end

  c = dyadicm({a,b},'xor',[],size(a,2));

return
