%MRDIVIDE Mapping overload

function c = mrdivide(a,b)

if ismapping(b)
	error('Operation not defined for mapping')
end
c = (1/b)*a;