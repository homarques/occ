%PLUS Mapping overload

function c = plus(a,b)

  if ~isa(a,'prmapping') 
    c = plus(b,a); 
    return
  end

  c = dyadicm({a,b},'plus',[],size(a,2));

return
