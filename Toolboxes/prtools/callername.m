%CALLERNAME
%
%	NAME = CALLERNAME
%
% Returns the name of the calling function 

function name = callername

[ss,i] = dbstack;
if length(ss) < 3
	name = [];
else
	name = ss(3).name;
end