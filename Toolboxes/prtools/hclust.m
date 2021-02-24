%HCLUST hierarchical clustering, faster version
% 
%  [LABELS, DENDRO] = HCLUST(D,TYPE,K,OLD)
%   DENDRO = HCLUST(D,TYPE)
% 
% INPUT
%  D     dissimilarity matrix
%  TYPE  string name of clustering criterion (optional)
%                 's' or 'single'   : single linkage (default)
%                 'c' or 'complete' : complete linkage
%                 'a' or 'average'  : average linkage 
%                                    (weighted over cluster sizes)
%  K     number of clusters (optional)
%  OLD   Logical, if TRUE return dendrogram in PRTools format. Default
%        FALSE
%
% OUTPUT
%  LABELS       vector with labels
%  DENDRO       arrsy with dendrogram
%
% DESCRIPTION 
% Computation of cluster labels and a clustering dendrogram for the
% objects with a given dissimilarity matrix D. K is the desired number of
% clusters.  The dendrogram may be plotted by PRTools's PLOTDG or by 
% Matlab's DENDROGRAM.
%
%   DENDRO = HCLUST(D,TYPE)
%
% As in this case no clustering level is supplied, just the entire
% dendrogram is returned. The first row now contains the object indices.
%
% Faster and more advanced tools for cluster analysis may be found in the
% <a href="http://37steps.com/clustertools">ClusterTools</a> toolbox.
%
% EXAMPLE
% a = gendats([25 25],20,5);     % 50 points in 20-dimensional feature space
% d = sqrt(distm(a));            % Euclidean distances
% dendg = hclustf(d,'complete'); % dendrogram
% plotdg(dendg)
% lab = hclust(d,'complete',2); % labels
% confmat(lab,getlabels(a));     % confusion matrix
%
% SEE ALSO (<a href="http://37steps.com/prtools">PRTools Guide</a>)
% PLOTDG, PRKMEANS, KCENTRES, MODESEEK, EMCLUST, DENDROGRAM.

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% $Id: hclust.m,v 1.3 2008/02/14 11:54:43 duin Exp $

function [labels, dendrogram] = hclust(D,type,k,old)   
  
  if nargin < 4 || isempty(old), old = false; end
	if nargin < 3 || isempty(k), k = []; end
	if nargin < 2 || isempty(type), type = 's'; end
	D = +D;
	[m,m1] = size(D);
	if m ~= m1
		error('Input matrix should be square')
  end
  if strcmp(type,'r') || strcmp(type,'central')
    Dorg = D;                
    L = 1:m;                 % temporary clustering 
    C = 1:m;                 % indices of cluster centra
  end
	D = D + diag(inf*ones(1,m));     % set diagonal at infinity.
	W = 1:m+1;               % starting points of clusters in linear object set.
	V = 1:m+2;               % positions of objects in final linear object set.
  R = 1:m;                 % rows/columns that still participate
	F = inf * ones(1,m+1);   % distance of next cluster to previous cluster 
                           % to be stored at first point of second cluster
  Z = ones(1,m); % number of samples in a cluster (only for average linkage)

  t = sprintf('Analysing %i cluster levels: ',m);
  prwaitbar(m,t);
	for n = 1:m-1
    prwaitbar(m,n,[t int2str(n)]);
		% find minimum distance D(i,j) i<j
		[di,I] = min(D(R,R)); 
		[dj,j] = min(di); 
		i = I(j);
		if i > j, j1 = j; j = i; i = j1; end
		% combine clusters i,j
		switch type
		case {'s','single'}
			D(R(i),R) = min(D(R(i),R),D(R(j),R));
		case {'c','complete'}
			D(R(i),R) = max(D(R(i),R),D(R(j),R));
		case {'a','average'}
			D(R(i),R) = (Z(i)*D(R(i),R) + Z(j)*D(R(j),R))/(Z(i)+Z(j));
			Z(i:j-1) = [Z(i)+Z(j),Z(i+1:j-1)]; Z(j) = [];
		case {'r','central'}
      Li = find(L==i);    % objects in cluster i 
      Lj = find(L==j);    % objects in cluster j
      L(Lj) = i*ones(size(Lj)); % assign cluster j to cluster i
      Lij = [Li Lj];      % merge the object indices
      centre = dclustk(Dorg(Lij,Lij),1); % centre of new cluster
      C(i) = Lij(centre(1)); % find its true object index and store it
      D(R(i),R) = Dorg(C(i),C); % update cluster distances
      C(j) = [];          % old centre can go
      LL = find(L>j);     % cluster indices above j ...
      L(LL) = L(LL)-1;    % ... need correction
		otherwise
			error('Unknown clustertype desired')
		end
		D(R,R(i)) = D(R(i),R)';
		D(R(i),R(i)) = inf;
    R(j) = [];
		% store cluster distance
		F(V(j)) = dj;
		% move second cluster in linear ordering right after first cluster
		IV = [1:V(i+1)-1,V(j):V(j+1)-1,V(i+1):V(j)-1,V(j+1):m+1];
		W = W(IV); F = F(IV);   
		% keep track of object positions and cluster distances
		V = [V(1:i),V(i+1:j) + V(j+1) - V(j),V(j+2:m-n+3)];
  end
  prwaitbar(0);
	if ~isempty(k) || nargout == 2
		if isempty(k), k = m; end
		labels = zeros(1,m); 
		[S,J] = sort(-F);      % find cluster level
		I = sort(J(1:k+1));    % find all indices where cluster starts
		for i = 1:k            % find for all objects cluster labels
			labels(W(I(i):I(i+1)-1)) = i * ones(1,I(i+1)-I(i));
		end                    % compute dendrogram
    if ~old
      dendrogram = [1:k; F(I(1:k))];
      dendrogram = pr2mat_den(dendrogram);
    else
      dendrogram = [I(2:k+1) - I(1:k); F(I(1:k))];
    end
		labels = labels';
	else
		labels = [W(1:m);F(1:m)]; % full dendrogram
    if ~old
      labels = pr2mat_den(labels);
    end
	end
return
	
