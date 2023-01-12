%PLUS. Mapping overload

function c = plus(a,b)
		sa = size(a);
sb = size(b);
if any(sa ~= sb)
		error('Mappings should have equal size')
end
if ~isa(a,'prmapping') % can this happen?
	c = b+a;
	return
end

if ~isaffine(a) || (isa(b,'prmapping') && ~isaffine(b))
	if isa(b,'double')
		b = affine(b);
	end
	k = size(a,2);
	w = dyadicm([],[],[],k);
	w.size_in = 2*k;
 	if isuntrained(a)
 		w.mapping_type = 'combiner';
 	end
	c = [a b]*w;
	c.labels = a.labels;
elseif isa(b,'prmapping')
	c = a;
	c.data.rot = c.data.rot + b.data.rot;
	c.data.offset = c.data.offset + b.data.offset;
elseif isa(b,'double')
	c = a;
	if length(b) == 1
		c.data.offset = c.data.offset + b;
	elseif all(size(b) == size(c.data.offset))
		c.data.offset = c.data.offset + b;
	elseif any(size(b) ~= size(c.data.rot))
		error('Mappings should have equal size')
	else
		c.data.rot = c.data.rot + b;
	end
end
return
