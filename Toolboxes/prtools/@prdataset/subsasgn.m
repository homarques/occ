%SUBSASGN Dataset overload

% Copyright: R.P.W. Duin
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% $Id: subsasgn.m,v 1.11 2010/01/24 00:04:18 duin Exp $

function a = subsasgn(a,s,b)

	[ma,ka] = size(a); [mb,kb] = size(b);
	row = []; 															% Row numbers to be changed.
	col = []; 															% Column numbers to be changed.

	if (strcmp(s(1).type,'.'))  		% Assignments of type A.PRIOR = B;
		if (length(s) > 1)
			error('Nested subscripted assigns not implemented for datasets')
		end
%  		a = set(a,s(1).subs,b); 			% s(1).subs should in this case be 'prior'.
   		a.(s(1).subs) = b; 		        % s(1).subs should in this case be 'prior'.
  		return
	end

  % From here on, assume a sub-assignment of type A(...) = B.

  if (length(s.subs) == 1)								% 1-D assignment.

  	if (isempty(s.subs{1}))  							% A([]) = B: do nothing.
  		;
  	elseif (strcmp(s.subs{1},':')) 				% A(:) = B: replace A's data by B's.
			if (max(size(b)) == 1), b = b*ones(size(a.data)); end;
  		a = setdata(a,b);
    else 
      if (min(size(b)) ~= 1) || (length(s.subs(1)) ~= length(b)) 
        error('Wrong data size for assignment.')
      elseif (~isa(b,'double'))
				error('Wrong data type for assignment.')
			else
	      a.data(s.subs{1}) = b;
			end;
    end
  		
  elseif (length(s.subs) == 2) 						% 2-D assignment.
                             
  	if (strcmp(s.subs{1},':'))   					% A(:,...) = ...
  		if (strcmp(s.subs{2},':')) 					% A(:,:) = B
				if (max(size(b)) == 1), b = b*ones(size(a.data)); end;
  			a = setdata(a,b);
  		elseif (isempty(b))        					% A(:,sub) = []
				for sub = flipud(sort(s.subs{2}(:))) % delete features in right order
  				a.data(:,sub)    = [];
          if ~isempty(a.featlab)
            a.featlab(sub,:) = [];
          end
          if ~isempty(a.featdom)
            a.featdom(sub)   = [];
          end
				end
  			a.featsize = size(a.data,2);
  		else                     						% A(:,sub) = B;
  			%SV (mb ~= 1) ???
        if (~(max(size(b)==1))) && (ma ~= mb)
					error('Wrong data size for assignment.'); 
				end
        featset = s.subs{2}(:)';
        if (length(featset)==1) && (ischar(b)) 	
				  % Define nominal features, e.g. a(:,3) = char('aa','bb','aa');
  				[data,domain] = renumlab(b);   	% Treat like labels:
  			  a.data(:,featset) = data;       %   [1 2 1]'
  			  % SV
          if isempty(a.featdom)
            a.featdom = cell(1, size(a.data, 2));
          end
          a.featdom(featset) = {domain}; 	%   ['aa';'bb']
        else					
  				% SV
          if (isa(b,'prdataset')) && (~isempty(a.featdom) || ~isempty(b.featdom)) 
            if isempty(a.featdom)
              a.featdom = cell(1, size(a.data, 2));
            end
            if isempty(b.featdom)
              b.featdom = cell(1, size(b.data, 2));
            end
          end
          j = 0;
          if islogical(featset)
            featset = find(featset);
          end
          for sub = featset 							% Copy feature J: A(:,sub) = B(:,J).
            j = j + 1;
            if (isa(b,'prdataset'))
              a.data(:,sub) = b.data(:,j);
              % SV
              if size(b.featlab, 1) >= j
                a.featlab(sub,:) = b.featlab(j,:);
              end  
              if ~isempty(a.featdom)
                a.featdom(sub) = b.featdom(j);
              end
            else
              a.data(:,sub) = b(:,j);			
              % SV
              testfeatdom(a,sub);				 % Test whether features fit domain.
            end
          end
  			end
  		end
  		return
  	else
  		row = s.subs{1}(:); 								% A(sub1,...) = B: store rows in row.
      if islogical(row), row = find(row); end
    end
    
  	% Handle second subscript in case of A(row,...) = ...
  	
    if (strcmp(s.subs{2},':')) 						% A(row,:) = .....
      if (isempty(b)) 						     		% A(row,:) = []
				L = [1:size(a,1)]';
				L(row) = [];
				a = reorderdset(a,L,0);           % trick to execute a = a(L,:), which sometimes fails
        return  			
  		else										            % A(row,:) = B
  			J = [1:length(row)]';
  			if (isa(b,'prdataset'))
  				if (~isequal(a.lablist,b.lablist))
  					error('Label list definitions and priors of datasets should be equal.')
  				end
  				a.data(row,:) = b.data;
          if ~isempty(a.targets)
            a.targets(row,:) = b.targets;
          end
					a.nlab(row,:) = b.nlab;
					a = setident(a,getident(b,''),[],row);
					%a.ident(row)= b.ident;
  			else
  				a.data(row,:) = b;
  			end
  		end
  	else
  		col = s.subs{2};										% A(row,col) = B
      if islogical(col), col = find(col); end
  	end
  		
  	if (~isempty(col)) && (~isempty(row))
  		if (length(col) == 1) && (ischar(b))  % Single feature with nominal value.
  			data = renumlab(b,a.featdom{col});
				
  			if data == 0
  				error(['''' b '''' ' is not in the feature domain'])
  			end

				% The numeric values related to nominal features
  			b = data; 											
  		end
  		a.data(row,col) = +b;  							% Replace old data by new data.
  		testfeatdom(a,col,row);							% Test whether features fit domain.
  	end
  else
  	error('Wrong number of subscripts.')
  end

return
  		
