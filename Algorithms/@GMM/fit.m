function obj = fit(X,k,varargin)
% Not intended to be called directly. Use FITGMDIST to fit a GMDISTRIBUTION.
%
%   See also FITGMDIST.

%   Copyright 2008-2013 The MathWorks, Inc.
%   Copyright 2008-2014 The MathWorks, Inc.


if nargin < 2
    error(message('stats:gmdistribution:TooFewInputs'));
end

checkdata(X);

if ~isscalar(k) || ~isnumeric(k) || ~isfinite(k) ...
         || k<1 || k~=round(k)
    error(message('stats:gmdistribution:BadK'));
end

%remove NaNs from X
wasnan = any(isnan(X),2);
hadNaNs = any(wasnan);
if hadNaNs
    warning(message('stats:gmdistribution:MissingData'));
    X = X(~wasnan,:);
end

[n, d] = size(X);
%if n <= d
%    error(message('stats:gmdistribution:TooFewN'));
%end

if n <= k
    error(message('stats:gmdistribution:TooManyClusters'));
end



% parse input and error check
pnames = {      'start' 'replicates'  'covariancetype' 'sharedcovariance'  'regularizationvalue'  'options'};
dflts =  { 'randSample'           1      'full'            false             0                     [] };
[start,reps, CovType,SharedCov, RegV, options,setflags,extraArgs] ...
    = internal.stats.parseArgs(pnames, dflts, varargin{:});

if  ~setflags.covariancetype || ~setflags.regularizationvalue
    pnames = {'covtype','regularize' };
    dflts = {'full'      0};
    [CovType_oldinput,RegV_oldinput] = internal.stats.parseArgs(pnames, dflts, extraArgs{:});
    if ~setflags.covariancetype
        %if 'covariancetype' is not used, accept 'covtype' for backward compatibility
        CovType = CovType_oldinput;
    end
    if ~setflags.regularizationvalue
        RegV =  RegV_oldinput;
    end
end

options = statset(statset('gmdistribution'),options);

if ~isnumeric(reps) || ~isscalar(reps) || round(reps) ~= reps || reps < 1
    error(message('stats:gmdistribution:BadReps'));
end

if ~isnumeric(RegV) || ~isscalar(RegV) || RegV < 0
    error(message('stats:gmdistribution:InvalidReg'));
end

varX = var(X) + RegV;
I = find(varX < eps(max(varX)));
if ~isempty(I)
    error(message('stats:gmdistribution:ZeroVariance', num2str( I )));
end

if ischar(CovType)
    covNames = {'diagonal','full'};
    i = find(strncmpi(CovType,covNames,length(CovType)));
    if isempty(i)
        error(message('stats:gmdistribution:UnknownCovType', CovType));
    end
    CovType = i;
else
    error(message('stats:gmdistribution:InvalidCovType'));
end

if ~islogical(SharedCov)
    error(message('stats:gmdistribution:InvalidSharedCov'));
end

options.Display = find(strncmpi(options.Display, {'off','notify','final','iter'},...
    length(options.Display))) - 1;

try
    [S,NlogL,optimInfo] =...
        gmcluster(X,k,start,reps,CovType,SharedCov,RegV,options);

    % Store results in object
    obj = GMM;
    obj.NDimensions = d;
    obj.NComponents = k;
    obj.PComponents = S.PComponents;
    obj.mu = S.mu;
    obj.Sigma = S.Sigma;
    obj.Converged = optimInfo.Converged;
    obj.Iters = optimInfo.Iters;
    obj.NlogL = NlogL;
    obj.SharedCov = SharedCov;
    obj.RegV = RegV;
    if CovType == 1
        obj.CovType = 'diagonal';
        if SharedCov
            nParam = obj.NDimensions;
        else
            nParam = obj.NDimensions * k;
        end
    else
        obj.CovType = 'full';
        if SharedCov
            nParam = obj.NDimensions * (obj.NDimensions+1)/2;
        else
            nParam = k*obj.NDimensions * (obj.NDimensions+1)/2;
        end

    end
    nParam = nParam + k-1 + k * obj.NDimensions;
    obj.BIC = 2*NlogL + nParam*log(n);
    obj.AIC = 2*NlogL + 2*nParam;

catch ME
    rethrow(ME) ;
end
