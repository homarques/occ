%FINDIDENT Determine indices of objects having specified identifiers
%
%   J = FINDIDENT(A,IDENT,FIELD)
%
% INPUT
%   A      Dataset
%   IDENT  Object identifiers, see SETIDENT
%   FIELD  Desired field, default 'IDENT'.
%
% If IDENT is a set of object identifiers then J is a vector with indices
% to the first object in A that matches IDENT in the specified FIELD.
% If IDENT is a single object identifier then J is a set of indices to
% all objects in A having the given identifier.

% $Id: findident.m,v 1.6 2010/01/15 13:45:06 duin Exp $

function J = findident(a,ident,field)

if nargin < 3, field = 'ident'; end

N = size(ident,1);
identa = getident(a,field);
if (iscellstr(ident) || ischar(ident)) && (iscellstr(identa) || ischar(identa))
	% compare strings
	J = match(ident,identa);
elseif ~iscell(identa) && ~ischar(identa) && ~iscell(ident) && ~ischar(ident)
	% just compare numbers
	J = match(ident,identa);
elseif iscell(ident) && iscell(identa)
	J = zeros(N,1);
	t = sprintf('Matching %i object identifiers: ',N);
	prwaitbar(N,t);
	for j=1:N
		x = zeros(length(identa),1);
		prwaitbar(N,j,[t num2str(j)]);
		for i=1:length(identa)
			x(i) = isequal(ident(j),identa(i));
		end
		J(j) = find(x);
	end
	prwaitbar(0)
else
	error('Ident field does not match')
end

return

function J = match(s1,s2)

	N = size(s1,1);
	if N==1
		if ischar(s1)
			J = strmatch(s1,s2);
		else
			J = find(s2==s1);
		end
	else
		J = zeros(N,1);
		t = sprintf('Matching %i object identifiers: ',N);
		prwaitbar(N,t);
		for j=1:N
			prwaitbar(N,j,[t num2str(j)]);
			K = strmatch(s1(j,:),s2);
			if isempty(K)
				K = 0;
			end
			J(j) = K(1);
		end
		prwaitbar(0);
	end
	
	return
	
