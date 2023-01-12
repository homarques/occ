%SUBSREF Subscripted reference. Datafile overload
%
% 
% $Id: subsref.m,v 1.8 2009/02/19 12:34:02 duin Exp $

function a = subsref(a,s)
  if strcmp(s(1).type,'.') % c = a.data type of reference
		a = get(a,s(1).subs);
		if length(s) > 1
			a = subsref(a,s(2:end));
		end
		
	elseif isempty(s.subs{1}) || (length(s.subs)>1 && isempty(s.subs{2}))
		
		a = prdatafile([]);
		
	else

		m = a.prdataset.objsize;
		if strcmp(s.subs{1},':')
			row = [1:m]; keep_row_size = 1;
		else
			row = s.subs{1}; keep_row_size = 0;
		end
		if size(s.subs,2) > 1 && ~strcmp(s.subs{2},':')
			error('Feature subscription for datafiles not possible')
		end
    a.prdataset = a.prdataset(row,:);
			
	end
	
return