%TIMES Mapping overload
%
% If W is a mapping then V=W.*X and V=X.*W define a new mapping V
% such that all output dimensions A*W are multiplied (scaled) by
% the corresponding elements of X. The length of the vector X
% should be equal to the output dimension of W. If X is a scalar
% it is applied to all output dimensions. 

% $Id: times.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function c = times(a,b)
		
    
    % This routine is bad as it performes multiplication before
    % normalizing the class outputs (classc). That is not what
    % users expect. (RD, Dec 2012)
    
    
sa = size(a);
sb = size(b);
if ~isa(a,'prmapping')
	c = b.*a;
	return
end
if ~isa(b,'double')
	error('Illegal data type')
end
if length(sb) > 2 || min(sb) > 1
	error('Second operand should be scalar or vector')
end
c = a;
if strcmp(c.mapping_file,'affine') && 0  % reconsider this special case!
	if length(b) == 1
		c.data.rot = c.data.rot * b;
		c.data.offset = c.data.offset * b;
	elseif max(sb) == sa(2)
		c.data.rot = c.data.rot * repmat(b,sa(1),1);
		c.data.offset = c.data.offset .* b;
	else
		error('vector length should equal number of mapping outputs')
	end
else
	if length(b) == 1
		c.scale = c.scale*b;
	else
		if max(sb) ~= c.size_out
			error('vector length should equal number of mapping outputs')
		end
		c.scale = a.scale.*b(:)';
	end
end
return
