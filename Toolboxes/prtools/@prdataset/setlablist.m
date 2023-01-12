%SETLABLIST Set names of classes or targets
%
%    A = SETLABLIST(A,LABLIST)
%
% LABLIST should be a column vector of C elements (integers, characters,
% or strings), in which C is the number of classes or targets of A.
% In case of multiple label lists this resets the current label list.
%
%    A = SETLABLIST(A)
%
% Removes entries in the lablist of A to which no objects are assigned,
% i.e. it remove empty classes. This command also removes duplicates in the
% lablist. An example of the merge of two classes in a 3-class dataset X
% with class names 'A', 'B' and 'C' can be realized by
%   X = setlablist(X,char('A','B','A'));
%   X = setlablist(X);
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% MULTI_LABELING

% Copyright: R.P.W. Duin
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% $Id: setlablist.m,v 1.10 2007/01/16 16:10:12 duin Exp $

function a = setlablist(a,lablist)

		
  if nargin > 1 && iscell(lablist)
		lablist = char(lablist);
	end

	 % set up multi-labels if needed and get current lablist
	[a,curn] = addlablist(a);   
	c = getsize(a,3);

	if nargin < 2 && islabtype(a,'crisp') 
								% no lablist, so remove empty classes
		if isempty(a), return; end
		
		% why was the following needed ??? It is time consuming!!
		%a = setlabels(a,getlabels(a)); 
		
		% find the classes that have objects
		L = zeros(1,c+1);       % prepare for unlabeled objects
		n = 0;
    S = classsizes(a);      % use of classsizes is faster
		for j = 1:c
			%if any(a.nlab(:,curn)==j)
      if S(j) > 0
				n = n+1; L(j+1)=n; % L(1) is for unlabeled objects
			end
		end
		N = find(L>0)-1;
		
		cc = length(N);
		lablista = a.lablist{curn,1};
	
		% correct admin in case some classes were empty
		if cc ~= c
			n = 0;
			% reset nlab for all objects
      if ~isempty(a.nlab)
        a.nlab(:,curn) = L(a.nlab(:,curn)+1);
      end
			% reduce label list
			lablista = lablista(N,:);			
			% reduce and renormalize priors
			if ~isempty(a.prior)
				priora = a.prior(N);
				priora = priora/sum(priora);
				a.prior = priora;
			end
		end
		
	elseif nargin < 2 && islabtype(a,'targets','soft')
		;  % don't do a thing, any label (i.e. target column) might be relevant
		return; %DXD
	else
		cc = size(lablist,1);
		% RD The following test was outcommented. May be it conflicts with some
		% routine. However, there should be test like this, so I made it active
		% again. The conflict should be solved otherwise.
		if ~isempty(a)
			maxnlab = max(a.nlab(:,curn));
			if cc < maxnlab
				error(['The label list should have at least ' num2str(maxnlab) ' elements'])
			end
		end
		lablista = lablist;

	end
	
	if (islabtype(a,'crisp','soft') && (cc > length(a.prior)))
		if ~isempty(a.prior)
			a.prior = [];
			prwarning(10,'Prior field of dataset reset to default')
		end
		if ~isempty(a.cost)
			a.cost = [];
			prwarning(10,'Cost field of dataset reset to default')
		end
	end

	a.lablist{curn,1} = lablista;
	a.lablist{curn,2} = a.prior;
	a.lablist{curn,3} = a.cost;
	
return
