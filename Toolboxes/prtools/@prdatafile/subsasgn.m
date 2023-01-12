%SUBSASGN Datafile overload

% Copyright: R.P.W. Duin
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% $Id: subsasgn.m,v 1.3 2009/11/27 08:56:47 duin Exp $

function a = subsasgn(a,s,b)

  if (strcmp(s(1).type,'.'))  		        % Assignments of type A.PRIOR = B;
		if (length(s) > 1)
			error('Nested subscripted assigns not implemented for datasets')
		end
    if isfield(struct(a),s(1).subs)               % real datafile field
      a.(s(1).subs) = b; 		        
    else                                  % try dataset
      a.prdataset.(s(1).subs) = b;
    end
	elseif strcmp(s(1).type,'()') && isempty(b)
		% statement like a(N,:) = []; tricky!!
		L = [1:size(a,1)];
		L(s(1).subs{1}) = [];
		a.prdataset = a.prdataset(L,:);
		a.prdataset = setident(a.prdataset,[1:length(L)]');
  else
    error('Assignment operation not defined for datafiles')
  end
  
 return
