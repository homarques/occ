%CLASSNAMES Get names of classes of dataset or classifier
%
%  NAMES = CLASSNAMES(A,C)
%  NAMES = CLASSNAMES(W,C)
%  NAMES = A*CLASSNAMES(C)
%  NAMES = W*CLASSNAMES(C)
%
% INPUT
%  A      Dataset
%  W      Trained classifier
%  C      Class number(s) in class label list, default: all
%
% OUTPUT
%  NAMES  Names of classes (strings or numbers)
%
% DESCRIPTION
% Returns the names of the classes used in the dataset A or the classes
% used by the classifier W. If for datasets no output is requested the
% names and the sizes of the classes are printed on the screen.
% If given, just the names of the classes corresponding to the indices in
% C are returned.
%
% SEE ALSO (<a href="http://37steps.com/prtools">PRTools Guide</a>)
% DATASETS, MAPPINGS, CLASSSIZES

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com

function out = classnames(varargin)

argin = shiftargin(varargin,'numeric');
argin = setdefaults(argin,[],[]);
if mapping_task(argin,'definition')
  out = define_mapping(argin,'combiner');
else
  [a,N] = deal(argin{:});
	if isa(a,'prdataset')
		lablist = getlablist(a);
		if nargout < 1 && islabtype(a,'crisp','soft')
			s = classsizes(a);
			if iscell(lablist), lablist = char(lablist); end
			if isempty(N), N = 1:size(lablist,1); end
			if ischar(lablist)
				for j=N
					if islabtype(a,'crisp')
						fprintf('\n %6i  %s',s(j),lablist(j,:));
					else
						fprintf('\n %8.2f  %s',s(j),lablist(j,:));
					end						
				end
			else
				for j=N
					if islabtype(a,'crisp')
						fprintf('\n %3i %6i',lablist(j),s(j));
					else
						fprintf('\n %3i %8.2f',lablist(j),s(j));
					end
				end
			end
			fprintf('\n\n');
		end
		names = lablist;
		
	elseif ismapping(a)
		if isuntrained(a)
			error('No classes defined for untrained classifiers or mappings')
		else
			names = getlabels(a);
		end
	else
		error('Dataset or trained classifier expected')
	end

	if ~isempty(N)
		names = names(N,:);
	end
	
	if nargout > 0 || ismapping(a) || islabtype(a,'targets')
		out = names;
  end
end
	
return
