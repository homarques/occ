%SETIDENT Set object identifiers
%
%   A = SETIDENT(A,IDENT,FIELD,L)
%
% INPUT
%   A      Dataset
%   IDENT  Object identifiers, size (N,K)
%   FIELD  Desired field, default 'IDENT'.
%   L      Vector of indices of objects to be updated (optional; default: all)
%          length(L) = N.
%
% OUTPUT
%   A      Updated dataset
%
% DESCRIPTION
% Set or reset the subfield FIELD of the ident field of A by IDENT.
% IDENT should be an array of size (N,K), with arbitrary K. 
%
% Note the ident field of datasets was originally intended for an
% identification of the individual objects. Later its usage was extended 
% to a field for storing general information on objects. For that reason 'old'
% datasets without a structure in the ident field are transformed such that
% this information is stored in a subfield IDENT in the ident field. It can
% be retrieved by GETIDENT(A,'IDENT').
%
% The default FIELD is 'IDENT'. To reset the entire IDENT give
% A = SETIDENT(A,IDENT,''), in which IDENT is a structure array of the
% right size and including a subfield named also IDENT.
%
% The new structure is checked or created by A = SETIDENT(A);
%
% Note also that for reasons of backward compatibility the parameter order
% of the SETIDENT command differs from similar Matlab commands like
% SETFIELD: first field content, then field name.

% $Id: setident.m,v 1.22 2010/01/15 13:46:36 duin Exp $

function a = setident(a,ident,field,J)

	m = size(a,1);
  
  if nargin == 1
	  if ~isstruct(a.ident) % very old format, reset it
          %a.ident.ident = a.ident;
          id.ident = a.ident;
          a.ident = id;
          clear id
    elseif prod(size(a.ident)) ~= 1 % old format, reset it
      fields = fieldnames(a.ident);
      for j=1:length(fields)
        s = {a.ident(1:end).(fields{j})};
		    ss = [s{:}]';
		    ss = reshape(ss,length(ss)/length(s),length(s))'; 
        aident.(fields{j}) = ss;
      end
      a.ident = aident;
	  end
    return
  end
	
	all = 0;
	if (nargin < 4 | isempty(J))
		J = [1:m]';
		all = 1;
	end
	
	if nargin == 3  % handle for backwards compatibility calls like 
		              % setident(a,ident,J);
		if ~ischar(field)
			J = field;
			field = 'ident';
		end
	end
	
	if nargin < 3
		field = 'ident';
  end
			
  if ~isempty(J)
    if (max(J) > m) | (min(J) < 1)
      error('Object indices out of range.')
    end
  end
  
	if isempty(ident) 
		if isfield(a.ident,field)
			a.ident = rmfield(a.ident,field);
			%ident = repmat(NaN,length(J),1);
		end
		return
  end

  if isempty(J)  % needed for datafiles as they have empty data field
    J = [1:size(ident,1)]';
    all = 1;
	end
	
	if ~isstruct(ident)
		if size(ident,1) == 1
			ident = repmat(ident,length(J(:)),1);
		end
		if (size(ident,1) ~= length(J(:))) 
			error('Numbers of identifiers and objects do not match.')
		end
	end
	
	if isempty(field)
		if ~isstruct(ident)
			error('ident field should be structure')
		end
		
    if all
      a.ident = ident;
    else  % private ranking
      fields = fieldnames(ident);
      for j=1:length(fields)
        f = ident.(fields{j});
				aidentfield = a.ident.(fields{j});
				aidentfield(J,:) = f;
        a.ident.(fields{j}) = aidentfield;
        %a.ident.(fields{j}) = f(J,:);
			end
		end
	else
    if all
			a.ident = setfield(a.ident,field,ident);
      %a.ident.(field) = ident;
    else
			if ~isfield(a.ident,field)
				a.ident = setfield(a.ident,field,cell(m,1));
			end
      f = a.ident.(field);
			if ischar(f) 
				f = cellstr(f);
				f(J) = cellstr(ident);
				f = char(f);
			else
				if any(size(f(J)) ~= size(ident))
					error('New identifiers do no fit in existing field')
				end					
      	f(J) = ident; 
			end
      a.ident.(field) = f;
    end
	end
	
return
