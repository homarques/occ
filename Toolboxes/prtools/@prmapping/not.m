%NOT Mapping overload

function c = not(a)

  c = dyadicm({a,1},'xor',[],size(a,2));

return
