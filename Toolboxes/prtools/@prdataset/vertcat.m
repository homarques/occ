%VERTCAT Vertical concatenation of datasets (object extension)
%
%    C = [A;B]
%
% The datasets A and B are vertically concatenated, i.e. the
% objects of B are added to the dataset A. This is possible if
% the labels of B are given in a similar way as those of A.
% If new labels (i.e. classes) are added, the PRIOR field of
% A is cleared.
%
% If A and B have multiple label sets, they should have the same 
% names for the label lists (see ADDLABELS) and the above should hold
% for each label set separately.
%
% In addition it is required that the object descriptions given in
% the IDENT field have the same subfields.
%
% If B is not a dataset, empty labels are generated.
%
% The new objects are checked for the feature domains.
%
% See also SETLABELS, TESTFEATDOM

% $Id: vertcat.m,v 1.13 2009/03/01 16:55:58 duin Exp $

function a = vertcat(varargin)
		
	a = varargin{1}; start = 2;
	if nargin == 1, return, end          % a call like A = [B]
	[m,k] = size(a);
	if (m==0 && k==0)                     % a call like A = [ []; B ...]
		if isdataset(a)
			a = prdataset(varargin{2});
		else
			a = varargin{2};
		end
		if length(varargin) == 2, return; end
		start = 3;
	end
	
	% make sure that for all datasets multiple labelings and new idents are set
	a = addlablist(a); 
	a = setident(a);
	for j=start:length(varargin)
		if ~isdataset(varargin{j})
			varargin{j} = prdataset(varargin{j});
		end
		varargin{j} = addlablist(varargin{j});
		varargin{j} = setident(varargin{j});
	end 
	         
	% do the easy concatenations fast
	while isequiv(a,varargin{start})
		b = varargin{start};
		a.data = [a.data; b.data];
		a.nlab = [a.nlab; b.nlab];
    a.targets = [a.targets; b.targets];
	  a.objsize = a.objsize + b.objsize;
		aident = a.ident;
		bident = b.ident;
    fields = fieldnames(aident);
		for j=1:length(fields)
			fa = aident.(fields{j});
			fb = bident.(fields{j});
			if ischar(fa) && ischar(fb)
				aident.(fields{j}) = char(fa, fb);  
			else
				aident.(fields{j}) = [fa; fb];
			end
		end
		a.ident = aident;
		if length(varargin) == start, return; end
		start = start+1;
	end
	
	if ~isa(a,'prdataset')
		error('First argument should be dataset');
	end
	[ma,ka] = size(a);

	alab = getlabels(a);
	for i=start:length(varargin)          % extend dataset a by b
		b = varargin{i};
		if ~isempty(b) 
			% add the dataset/matrix
%			if ~isa(b,'prdataset')
%				if size(a.lablist,1) > 2
%					error('Cannot concatenate dataset with multiple labels with plain data')
%				end
%				if ~islabtype(a,'crisp')
%					error('Cannot concatenate non-crisp dataset with plain data')
%				end
%				b = prdataset(b);
%			end

			[mb,kb] = size(b);
			
			% fix the label sets of both datasets

			for j=1:size(a.lablist,1)-1
				
				switch a.lablist{j,4}
					
					case 'crisp'
						if isempty(a.lablist{j,1}) && isempty(b.lablist{j,1})
							; % everything OK
						elseif isempty(b.lablist{j,1})
							; % everything OK
						elseif isempty(a.lablist{j,1})
							a.lablist{j,:} = b.lablist{j,:}; % use b
						else
							c = size(a.lablist{j,1},1);
							% where are labels for b in lablist of a?
							L = matchlablist(b.lablist{j,1},a.lablist{j,1});
							% find new ones
							Lzero = find(L==0);
							% extend lablist
							if ischar(a.lablist{j,1})
								a.lablist{j,1} = char(a.lablist{j,1},b.lablist{j,1}(Lzero,:));
							else
								a.lablist{j,1} = [a.lablist{j,1};b.lablist{j,1}(Lzero,:)];
							end
							% give nlab of b index number of the joint lablist
							L(Lzero) = [c+1:c+length(Lzero)];
              LL = [0; L];  % take care of zero nlabs
							b.nlab(:,j) = LL(b.nlab(:,j)+1);
							if ~isempty(Lzero)         % if lablist changed then
								a.lablist(j,2:3) = {[]}; % reset priors and costw
							elseif ischar(a.lablist{j,1})
								a.lablist{j,1}(end,:) = [];  % seems to be unnecessary
							end
							%a = setlablist(a);
						end
							
					case 'soft'
						L = matchlablist(b.lablist{j,1},a.lablist{j,1});
            btargets = gettargets(changelablist(b,j));
            b = settargets(b,btargets(:,L));
% 						b.targets{j} = b.targets{j}(:,L);
						b.nlab(:,j) = L(b.nlab(:,j));
					case 'targets'
						L = matchlablist(b.lablist{j,1},a.lablist{j,1});
            btargets = gettargets(changelablist(b,j));
            b = settargets(b,btargets(:,L));
% 						b.targets{j} = b.targets{j}(:,L);
					otherwise
						error('Unknown')
				end
						
			end
			
			% do the real work:
			%a.data = [a.data; b.data];
			a.nlab = [a.nlab; b.nlab];
      a.targets = [a.targets; b.targets];
% 			for j = 1:length(a.targets)
% 				a.targets{j} = [a.targets{j}; b.targets{j}];
% 			end
			
			aident = a.ident;
			bident = b.ident;
  		fields = fieldnames(aident);
  		for j=1:length(fields)
    		fa = aident.(fields{j});
				fb = bident.(fields{j});
        if ischar(fa) && ischar(fb)
          aident.(fields{j}) = char(fa, fb);  
        else
          aident.(fields{j}) = [fa; fb];  
        end
          
    		
			end
			a.ident = aident;
			a.objsize = a.objsize + b.objsize;
      
      fa = getfeatdom(a);
      fb = getfeatdom(b);
      if ~isequal(fa,fb)
        [RA,JA,CA] = feattypes(a);
        [RB,JB,CB] = feattypes(b);
        if ~isequal(CA,CB)
          error('Datasets have different features that are categorical')
        end
        xa = dset2cell(a);
        xb = dset2cell(b);
        for j = [RA,JA]
          xa{j} = [xa{j}; xb{j}];
        end
        for j= CA
          xa{j} = char(xa{j},xb{j});
        end
        aa = cell2dset(xa);
        a.data = aa.data;
        a = setfeatdom(a,getfeatdom(aa));
      else
        a.data = [a.data; b.data];
      end
      
			testfeatdom(a,[],[ma+1:ma+mb]);
		end
	end  % end loop over the varargin
	a.objsize = size(a.data,1);
	a.prior = a.lablist{curlablist(a),2};
	a.cost = a.lablist{curlablist(a),3};

return

function n = isequiv(a,b)
	% find equivalent datasets
	n = 0; 
	if isempty(b), return; end  %DXD: allow for empty datasets
	if ~isdataset(b), return; end
	if size(a,2) ~= size(b,2)
		error('datasets should have equal numbers of features');
	end
	if (size(a.lablist,1) ~= size(b.lablist,1)) || ...
			~all(strcmp(cellstr(a.lablist{end,1}),cellstr(b.lablist{end,1})))
		error('datasets should have identical label list sets')
	end
  aidentfields = fieldnames(a.ident);
  bidentfields = fieldnames(b.ident);
  for j = 1:size(bidentfields,1)
    k = strmatch(bidentfields{j},aidentfields,'exact');
    if isempty(k)
  		error('Datasets ident fields do not match')
    end
	end
  for j = 1:size(aidentfields,1)
    k = strmatch(aidentfields{j},bidentfields,'exact');
    if isempty(k)
  		error('Datasets ident fields do not match')
    end
	end
	for j=1:size(a.lablist,1)-1
		if size(a.lablist{j,1}) ~= size(b.lablist{j,1}), return, end
		if ~strcmp(a.lablist{j,4},b.lablist{j,4})
			error('Label lists should have same label types for both datasets')
		end
		if ischar(a.lablist{j,1}) ~= ischar(a.lablist{j,1})
			error('Corresponding label lists of datasets should be both strings or be both numeric')	
		end
		L = matchlablist(b.lablist{j,1},a.lablist{j,1});
		if any(L ~= [1:length(L)]'), return; end
		%check priors and costs
		if isempty(a.lablist{j,2}) ~= isempty(b.lablist{j,2}), return; end 
		if isempty(a.lablist{j,3}) ~= isempty(b.lablist{j,3}), return; end
		if any(a.lablist{j,2} ~= b.lablist{j,2}), return; end
		if any(a.lablist{j,3} ~= b.lablist{j,3}), return; end
    if size(aidentfields,1) ~= size(bidentfields,1), return; end
  end
  if ~isequal(getfeatdom(a),getfeatdom(b)), return; end
	n = 1;
return
