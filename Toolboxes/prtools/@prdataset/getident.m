%GETIDENT Get fields of object descriptors
%
%    IDENTFIELD = GETIDENT(A,FIELD,L)
%
% INPUT
%   A          Dataset
%   FIELD      Character string: name of structure field of IDENT field of A.
%   L          Vector of indices pointing to desired objects in A, 
%              default: all.
%
% OUTPUT
%   IDENTFIELD Cell array of size (L,1) containing the requested field of the
%              objects A(L,:).
%
% If FIELD is the empty string ('') the entire ident structure is returned.
% If the requested field does not exist IDENTFIELD = [];
%
% Note the ident field of datasets was originally intended for an
% identification of the individual objects. Later its usage was extended 
% to a field for storing general information on objects. For that reason 'old'
% datasets without a structure in the ident field are transformed such that
% this information is stored in a subfield IDENT in the ident field. It can
% be retrieved by GETIDENT(A) or GETIDENT(A,J).
%
% IDENTFIELD is a cell array as arbitrary parameters may be stored. If
% these are doubles, e.g. after A = SETIDENT(A,[1:SIZE(A,1)]'), they can
% be easily converted by N = CELL2MAT(GETIDENT(A));
%
% For backward compatibility the following holds: If FIELD = 'string'
% then IDENTFIELD contains a character array of the object identifiers stored
% in A.IDENT.IDENT. If these are integers they are converted to strings.

% $Id: getident.m,v 1.10 2009/01/04 19:28:19 duin Exp $

function s = getident(a,field,J)
		
  %a = setident(a); % convert old formats to new
	ident = a.ident;

	if nargin < 3
		J = [];
	end
	
	if nargin < 2
		field = 'ident';
	end
	
	if isempty(J) && ~ischar(field) % allow for old call: getident(a,J)
		J = field;
		field = 'ident';
	end
	
	if ~ischar(field)
		error('Ident field should be given as string')
	end
	
	if strcmp(field,'')               % return everything
		s = ident;
    if ~isempty(J)
      fields = fieldnames(ident);
      for j=1:size(fields,1)
        field = ident.(fields{j});
        s.(fields{j}) = field(J,:);
      end
    end
		return
	elseif strcmp(field,'string')     % 'string' is reserved to return ident field as chars
		ident = ident.ident;            % for plotting purposes
		if iscellstr(ident)
			s = char(ident);
		elseif ischar(ident)
			s = ident;
		elseif iscell(ident)
			s = num2str(cell2mat(ident));
		else
			s = num2str(ident);
		end
		return
	elseif ~isfield(ident,field)
		prwarning(3,['Reference to non-existent field ''' field '''.']);
		s = [];
		return
	else
		s = ident.(field);
	end

	if ~isempty(J)
		if (max(J) > size(s,1)) || (min(J) < 1)
			error('Object indices out of range.')
		end
		if iscell(s) && length(J) == 1
			s = s{J};
		else
			s = s(J,:);
		end
	end
	
return
