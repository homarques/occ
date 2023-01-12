%KMEANS PRTools k-means clustering, deprecated
%
%   [LABELS,B] = KMEANS(A,K,MAXIT,INIT)
%
% INPUT
%  A       Dataset
%  K       Number of clusters to be found (optional; default: 2)
%  MAXIT   maximum number of iterations (optional; default: 50)
%  INIT    Labels for initialisation, or
%          'rand'     : take at random K objects as initial means, or
%          'kcentres' : use KCENTRES for initialisation (default)
%
% OUTPUT
%  LABELS  Cluster assignments, 1..K
%  B       Dataset with original data and labels LABELS: 
%          B = PRDATASET(A,LABELS)
% 
% DESCRIPTION
% K-means clustering of data vectors in A. This routine calls PRKMEANS
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% DATASETS, PRKMEANS, HCLUST, KCENTRES, MODESEEK, EMCLUST, PRPROGRESS

% Copyright: R.P.W. Duin
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function [assign,a] = kmeans(a,varargin)

persistent kmeans_warning
if isempty(kmeans_warning)
  warning('Use of ''kmeans'' is deprecated. Use ''prkmeans'' instead');
  kmeans_warning = 1;
end

[assign,a] = prkmeans(a,varargin{:});
	
return;
