%ORTH Orthogonalisation of an affine mapping
%
%  V = ORTH(W)
%
%In case W is an affine mapping it is orthogonalised. Otherwise
%an error is generated. The output mapping V has no offset and has
%thereby a distance zero to the origin.
%
%SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>) 
%MAPPINGS, AFFINE

function w = orth(w)

		
	isaffine(w);
	
	if size(w.data.rot,1) ~= 1
		rot = orth(w.data.rot);
		off = zeros(1,size(rot,2));
		w.data.rot = rot;
		w.data.offset = off;
	end
	
return