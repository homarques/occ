%LT Mapping overload

function c = lt(a,b)

  if ~isa(a,'prmapping') 
    c = ge(b,a); 
    return
  end

  c = dyadicm({a,b},'lt',[],size(a,2));

return

