%GETUSER Return the user field of a mapping
%
%    USERFIELD = GETUSER(W,FIELD,SUB)
%
% INPUT
%   W          Mapping
%   FIELD      Character string: name of structure field of USER field of W.
%   SUB        Sub-field or cell index, default: return entire field.
%
% OUTPUT
%   USERFIELD  Requested field
%
% If FIELD is is the empty string ('') the entire user field is returned. 
%
% If the requested field does not exist USERFIELD = [];
%
% Note the the USER field of mappings was originally intended for a user
% defined description of mappings. Later its usage was extended to a field
% for storing general information on mappings. For that reason 'old'
% mappings without a structure in the user field are transformed such that
% this information is stored in a subfield USER in the user field. It can
% be retrieved by GETUSER(W).

function out = getuser(w,field,sub)

	if nargin < 3, sub = []; end
	user = w.user;
	if ~isstruct(user)    % convert to expected structure if needed
		user.user = user;
	end
	
	if nargin < 2
		field = 'user';
	end
	
	if ~ischar(field)
		error('User field should be given as string')
	end
	
	if strcmp(field,'')               % return everything
		s = user;
	elseif ~isfield(user,field)
		s = [];
	else
		s = getfield(user,field);
  end
  
  if ~isempty(sub)
    if isstruct(s)
      s = getfield(s,sub);
    elseif iscell(s)
      s = s{sub};
    end
  end
	if nargout == 0
		if ischar(s)
			disp(' ')
			disp(strvcat(textwrap({s},80)));
			disp(' ')
		elseif iscellstr(s)
			for j=1:length(s)
				disp(' ')
				disp(strvcat(textwrap(s(j),80)));
				disp(' ')
			end
		else
			out = s;
		end
	else
		out = s;
	end
  
return;
