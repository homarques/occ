%NE Mapping overload

function c = ne(a,b)

  if ~isa(a,'prmapping') 
    c = ne(b,a); 
    return
  end

  c = dyadicm({a,b},'ne',[],size(a,2));

return
