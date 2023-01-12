%RDIVIDE Mapping overload

function c = rdivide(a,b)

  if ~isa(a,'prmapping') 
    c = ldivide(b,a); 
    return
  end

  c = dyadicm({a,b},'rdivide',[],size(a,2));

return
