%SELPROTF Select prototypes from dataset by FFT or WFT procedure
% 
%  [P,I,J,D,NDIST] = SELPROTF(A,N,DIST,TYPE,INIT)
%  [P,I,J,D,NDIST] = A*SELPROTF(N,DIST,TYPE,INIT)
% 
% INPUT
%   A      PRTools dataset or double matrix
%   N      Scalar, number of prototypes to be selected. 
%          If N is a row vector with as many elements as A has classes,
%          the selection is done clas wise.
%          If 0 < N < 1, the corresponding fraction of A is selected.
%          Default is N = 1.
%  DIST    Distance function (name or handle) or mapping to be used for
%          clustering. Default: @DISTM for Euclidean distances. See below.
%  TYPE    Character string naming the algorithm, either 'f' for the FFT 
%          (Farthest First Traversal) algorithm or 'w' for the WFT (Worst
%          First Traversal) algorithm. The latter takes the farthest in
%          ranking instead of the farthest in distance. Default is FFT.
%  INIT    Index of object in A taken for initialisation. It will be
%          excluded from the prototypes. Default is a random object.
%
% OUTPUT
%   P      PRTools dataset, or double matrix in case A is double,
%          containing the selected prototypes. If TYPE is 'M' these are not
%          objects from  A and P is a double array.
%   I      The indices of the selected objects in A, P = A(I,:). I = NaN in
%          case TYPE is 'M'. 
%   J      Indices of the not-selected objects. 
%   D      PRTools dataset with resulting distances between A and P.
%   NDIST  Total number of distance computations
%
% DESCRIPTION
% This routine selects some possibly interesting objects, e.g. for building
% a representation set from a feature representation by the FFT (Farthest 
% First Traversal) algorithm. It starts with the most remote object from a
% a given (by INIT) or randomly generated object. This object itself is
% excluded from the resulting set of prototypes.
% deterministic solution.
%
% If DIST is a function it is expected to take two double arrays as input
% arguments: if D = DIST(A1, A2) then SIZE(D) is [SIZE(A1, 1) SIZE(A2, 1)].
% If DIST is a PRTools mapping then it should be possible to use it like 
% D = A1*(A2*DIST), i.e. it has to be a trainable mapping and it should be
% able to convert double arrays automatically into datasets. E.g., for
% PROXM it is possible to call SELPROTF(A,N,PROXM), but for DISTM we need
% to use SELPROTF(A,N,@DISTM) or SELPROTF(A,N,'distm').
% 
% EXAMPLE
% % compute a dissimilarity based classifier for a representation set of
% % 10 objects using a Minkowski-1 distance for prototype selection as well
% % as for representation.
% a = gendatb;
% v = proxm('m',1)
% u = selprotf(10,v)*v*fisherc;
% w = a*u;
% scatterd(a)
% plotc(w)
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% DATASETS, MAPPINGS, GENDAT, RANDRESET, PRKMEANS, KCENTRES

% Copyright: R.P.W. Duin
%%

function [p,I,J,d,ndist] = selprotf(varargin)

%% mapping definition
  argin = shiftargin(varargin,{'scalar','vector'});
	argin = setdefaults(argin,[],1,[],'f',[]);
  if mapping_task(argin,'definition')
    p = define_mapping(argin,'generator','Prototype selection');
    return
  end
  
%% start mappping execution

  % get and check parameters
  [a,n,dist,type,init] = deal(argin{:});
  if isempty(dist) && ~isoctave
    dist = @pdist2;
  end
  m = size(a,1);
  if isempty(init)
    init = randi(m);
  end
  
  x = +a;
  fft = strncmpi(type,'f',1);
  y = x(init,:);
  I = zeros(n,1);
  d = zeros(m,n);
  [~,I(1)] = max(distf(x,y,dist));
  ndist = size(x,1)*size(y,1);
  y = x(I(1),:);
  d(:,1) = distf(x,y,dist);
  ndist = ndist+size(x,1)*size(y,1);
%   t = sprintf([upper(type) 'FT selection of %i prototypes: '],n);
%   prwaitbar(n,t);
  for i=2:n
%     prwaitbar(n,i,[t num2str(i)]);
    if fft
%         take the farthest in distance
      dmin   = min(d(:,1:i-1),[],2);
    else
%         take the farthest in ranking
      dmin = min(d(:,1:i-1)*argsort,[],2);
    end
    [~,I(i)] = max(dmin);
    y      = x(I(i),:);
    d(:,i) = distf(x,y,dist);
    ndist = ndist+size(x,1)*size(y,1);
  end
%   prwaitbar(0);
  p = a(I,:);
  J = setxor(I,(1:m)');
      
end

function d = distf(a,b,dist)
  if  ismapping(dist)
    d = a*(b*dist);
  elseif ischar(dist)
    d = feval(dist,a,b);
  elseif isa(dist,'function_handle')
    d = dist(a,b);
  elseif isempty(dist)
    d = sqrt(distm(a,b));
  else
    error('Illegal distance definition')
  end
end

        
