%MAP Map a dataset, train a mapping or classifier, or combine mappings
%
%	B = MAP(A,W) or B = A*W
%
% Maps a dataset A by a fixed or trained mapping (or classifier) W,
% generating
% a new dataset B. This is done object by object. So B has as many objects
% (rows) as A. The number of features of B is determined by W. All dataset
% fields of A are copied to B, except the feature labels. These are defined
% by the labels stored in W.
%
%	V = MAP(A,W) or B = A*W
%
% If W is an untrained mapping (or classifier), it is trained by the dataset A.
% The resulting trained mapping (or classifier) is stored in V.
%
%	V = MAP(W1,W2) or V = W1*W2
%
% The two mappings W1 and W2 are combined sequentially. See SEQUENTIAL for
% a description. The resulting combination is stored in V.
%
% See also DATASETS, MAPPINGS, SEQUENTIAL

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com


function varargout = map(varargin)
    
warning('PRTools MAP is deprecated, use PRMAP instead.')

varargout = cell(1,nargout);
[varargout{:}] = feval('prmap',varargin{:});
return


