%FEAT2LAB  Label dataset by one of its features and remove this feature
%
%   B = FEAT2LAB(A,N)
%
% INPUT
%   A   Dataset
%   N   Integer, pointing to feature to be used as label
%
% OUTPUT
%   B   Dataset, feature N is removed and used for labeling
%
% SEE ALSO (<a href="http://37steps.com/prtools">PRTools Guide</a>)
% DATASETS, SETFEATDOM, GETFEATDOM

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function a = feat2lab(a,n,par)

isdataset(a);
k = size(a,2);

if (n<1) || (n>k)
  error('Desired feature not in range')
end

lablist = getfeatdom(a,n);
lablist = lablist{1};
labs = +a(:,n);
a(:,n) = [];
if isempty(lablist) || ~ischar(lablist)
  [nlab,lablist] = renumlab(labs); % numeric labels
else
  nlab = labs; % index in lablist retrieved from featdom
end

if nargin > 2 % not recommended, orinal labeling will miss a feature
  if ischar(par)
    lablistname = par;
    curn = curlablist(a);
    a = addlablist(a,lablist,lablistname);
    a = setnlab(a,nlab);
    a = changelablist(a,curn);
  elseif isvector(par) 
    % split contineous regression values in discrete labels
    if any(par <= 0) || any(par >= 1)
      error('Histogram edges should be a set of percentiles < 1')
    end
    par = sort(par);
    m = size(a,1);
    [~,L] = sort(labs,1);
    labels = ones(m,1);
    for i=1:numel(par)
      S = [1:m]' > round(par(i)*m);
      labels(L(S)) = i+1;
    end
    a = setlabels(a,labels);
  end
else
  a = setlablist(a,lablist);
  a = setnlab(a,nlab);
end