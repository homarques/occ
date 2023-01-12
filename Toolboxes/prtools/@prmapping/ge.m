%GE Mapping overload

function c = ge(a,b)

  if ~isa(a,'prmapping') 
    c = lt(b,a); 
    return
  end

  c = dyadicm({a,b},'ge',[],size(a,2));

return

