%ISAFFINE Test affine mapping
%
%    I = ISAFFINE(W)
%    ISAFFINE(W)
%
% I is true if W is an affine mapping.
% If called without an output argument ISAFFINE generates an error
% if W is not an affine mapping.

% $Id: isaffine.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function i = isaffine(w)
		if isstacked(w) || isparallel(w)
	J = zeros(1,length(w.data));
	for j=1:length(w.data);
    if ismapping(w.data{j})
      J(j) = isaffine(w.data{j});
    else
      J(j) = 0;
    end
	end
	i = all(J);
else
	i = strcmp(getmapping_file(w),'affine');
end

if nargout == 0 && i == 0
	error([prnewline '---- Affine mapping expected ----'])
end
return
