%SUBSREF Subscript reference overload of mapping
%
% This routine enables constructions like DATA = W.DATA,
% which is similar to DATA = GETDATA(W).
%
% In addition V = W(I,J) is supported for affine transformations.
% It is again an affine mapping using the [I,J] block of the
% rotation matrix and the elements J of the support vector.
%
% For arbitrary mappings just V = W(:,J) is defined by output
% selection: A*V returns just the features J of A*W.

% $Id: subsref.m,v 1.8 2010/05/03 15:12:20 duin Exp $

function w = subsref(v,s)
			if strcmp(s(1).type,'.')
				% looking for a field like v.data
		switch s(1).subs
		case {'MAPPING_FILE','mapping_file'}
			w = v.mapping_file;
		case {'MAPPING_TYPE','mapping_type'}
			w = v.mapping_type;
		case {'DATA','data'}
			w = v.data;
		case {'LABELS','labels'}
			w = v.labels;
		case {'SIZE_IN','size_in'}
			w = v.size_in;
		case {'SIZE_OUT','size_out'}
			w = v.size_out;
		case {'SIZE','size'}
			w = size(v);
		case {'SCALE','scale'}
			w = v.scale;
		case {'OUT_CONV','out_conv'}
			w = v.out_conv;
		case {'NAME','name'}
			w = v.name;
		case {'COST','cost'}
			w = v.cost;
		case {'USER','user'}
			w = v.user;
		case {'VERSION','version'}
			w = v.version;
    otherwise
			error('Unknown dataset field')
		end
		% take care of nested subsrefs, like in:
		%        w = gaussm(gendath,2)
		%        w.data{1}.data{2}.data.mean
		if length(s) > 1
			w = subsref(w,s(2:end));
		end
		
	elseif strcmp(s(1).type,'{}')
			% subscripting an element of v.data if it is a cell-array
		if ~iscell(v.data)
			error(['Mapping parameters can now be extracted as a structure field data' ...
						prnewline 'for example, for a mapping w: w.data or +w'])
		end
		[m1,m2] = size(v.data);
		if length(s(1).subs) == 1
			if strcmp(s(1).subs{1},':')
				w = v.data{:};
			else
				w = v.data{s(1).subs{1}};
			end
		else
			if strcmp(s(1).subs{1},':')
				row = [1:m1];
			else
				row = s(1).subs{1};
			end
			if strcmp(s(1).subs{2},':')
				col = [1:m1];
			else
				col = s(1).subs{1};
			end
			w = v.data{row,col};
		end
		
		if length(s) > 1
			w = subsref(w,s(2:end));
		end
		
	elseif ismapping(v) && numel(s(1).subs(:))==1 && isdataset(s(1).subs{:})
		  % something like 
			% w = ldc([],1e-6)
			% w(a)
			w = s(1).subs{:}*v;
	elseif (strcmp(s(1).type,'()') && isuntrained(v))
			% facilitate constructions like
			% w = ldc;
			% a*(w([],1e-6))
		w = feval(v.mapping_file,s(1).subs{:});
	else
		% subscripting a mapping by w(i,j)
		% well defined for affine transforms
		% output selection is always possible, e.g. w(:,[2 5 7])
		if length(s.subs) < 2
			error('Mapping subscription should be 2-dimensional, e.g. w(:,3)')
		end
		if isempty(s.subs{1}) || isempty(s.subs{2})
			w = [];
		elseif strcmp(v.mapping_file,'affine')  % well defined for affine transforms
			v.data.rot = v.data.rot(s.subs{1},s.subs{2});
			v.data.offset = v.data.offset(s.subs{2});
			if ~isempty(v.labels), v.labels = v.labels(s.subs{2},:); end
			if ~strcmp(s.subs{2},':'), v.size_out = length(s.subs{2}); end
			if ~strcmp(s.subs{1},':'), v.size_in  = length(s.subs{1}); end
			w = v;
		elseif ~strcmp(s.subs{1},':')
			error('Input selection impossible for mapping')
		elseif (length(s.subs{2}) == 1) &&  (s.subs{2} == ':')
			w = v; % want everything, so, do nothing
		else
			col = s.subs{2};
			%DXD: here I introduce the possibility to use named indices,
			% i.e. instead of numeric indices we can use the feature
			% names.
			if ~isa(col,'double')
				% all character arrays and cell-arrays are allowed
				if isa(col,'char')
					col = cellstr(col);  % convert character arr -> cell
				end
				%(DXD: I should check if the contents of a cell array are
				%  indeed strings??)
				
				% now match the names with the feature labels:
				fl = v.labels;
				newcol = [];
				for i=1:length(col)
					id = strmatch(col{i},fl);
					% Give a warning when we cannot find it (No error, to
					% avoid that your whole endless experiments crash).
					if isempty(id)
						warning('Feature %s is not present in the dataset.',col{i});
					else
						newcol = [newcol; id];
					end
				end
				col = newcol;
			end
			% and this is the output selection
			%w = v*cmapm(size(v,2),s.subs{2});
			w = v*cmapm(size(v,2),col);
			labels = getlabels(v);
			if ~isempty(labels)
				w = setlabels(w,labels(col,:));
			end
		end
	end	

return
