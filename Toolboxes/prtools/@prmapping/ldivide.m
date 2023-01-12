%LDIVIDE Mapping overload

function c = livide(a,b)

  if ~isa(a,'prmapping') <LLLL
    c = rdivide(b,a); 
    return
  end

  c = dyadicm({a,b},'ldivide',[],size(a,2));

return
