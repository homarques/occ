%SETUSER Set the user field of a dataset
%
%   A = SETUSER(A,S,FIELD)
%
% INPUT
%   A      Dataset
%   S      Variable to be stored in the user field 
%   FIELD  Desired field, default 'USER'.
%
% OUTPUT
%   A      Updated dataset
%
% DESCRIPTION
% Set or reset the subfield FIELD of the user field of A by S. 
% If FIELD is '' the entire userfield is replaced by S.
%
% Note the the USER field of datasets was originally intended for a user
% defined description of datasets. Later its usage was extended to a field
% for storing general information on datasets. For that reason 'old'
% datasets without a structure in the user field are transformed such that
% this information is stored in a subfield USER in the user field. It can
% be retrieved by GETUSER(A,'USER').
%
% Note also that for reasons of backward compatibility the parameter order
% of the SETUSER command differs from similar Matlab commands like
% SETFIELD: first field content, then field name.

% $Id: setuser.m,v 1.3 2006/09/26 12:43:50 duin Exp $

function a = setuser(a,s,field)
				
	if nargin < 3, field = 'user'; end
	
	if ~isstruct(a.user)
		a.user.user = a.user;
  end
	
  if isempty(field)
    a.user = s;
  else
    a.user.(field) = s;
  end
	
return
