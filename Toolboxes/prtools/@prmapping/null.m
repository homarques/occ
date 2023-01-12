%NULL Oveload null space of affine mapping

function  v = null(w)

isaffine(w);
v = affine(null(w.data.rot'));
