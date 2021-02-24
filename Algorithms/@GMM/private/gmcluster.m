function [S,NlogL,optimInfo]...
    =gmcluster(X,k,start,reps, CovType,SharedCov, RegV, options)
%GMCLUSTER Gaussian mixture fit.
%   S = GMCLUSTER(X,K) fits a K-component Gaussian mixture model to the
%   data.  The fit maximizes the log-likelihood of the data using
%   Expectation Maximization (EM). Rows of X correspond to points, columns
%   correspond to variables. GMCLUSTER returns the estimated parameters in
%   a structure S which contains the following fields:
%      PComponents  A 1-by-K vector containing the mixing
%                           proportions of each component.
%      mu     A K-by-D matrix containing the means of each component.
%             S.mu(j,:) is the mean of component j.
%      Sigma  An array or a matrix containing the covariance of each
%             component. The size of Sigma is:
%             o D-by-D-by-K array if there are no restrictions on the
%               the form of covariance. In this case, S.Sigma(:,:,j) is the
%               covariance of component j.
%             o 1-by-D-by-K array if the covariance matrices are
%               restricted to be diagonal, but not restricted to be the
%               same across components. In this case, S.Sigma(:,:,j) contains
%               the diagonal elements of the covariance of component j.
%             o D-by-D matrix if the covariance matrices are restricted to
%               be the same across components, but not restricted to be
%               diagonal. In this case, S.Sigma is the pooled estimate of
%               covariance.
%             o 1-by-D vector if the covariance matrices are restricted
%               to be diagonal and to be the same across components.  In this
%               case, S.Sigma contains the diagonal elements of the
%               pooled estimate of covariance.
%
%   [S,NLOGL] = GMCLUSTER(X,K) returns the negative of the
%   log-likelihood of the mixture.
%
%   [S,NLOGL,OPTIMINFO] = GMCLUSTER(X,K) returns information about the
%   iterative EM algorithm in a structure OPTIMINFO containing the
%   following fields:
%
%      Converged  True if the algorithm has converged; false if the
%                 algorithm has not converged.
%      Iters      The number of iterations of the algorithm.
%
%   GMCLUSTER treats NaNs as missing data. Rows of X with NaNs are excluded
%   from the partition.
%
%   [ ... ] = GMCLUSTER(...,start,reps, CovType,SharedCov, RegV,
%   options,...) provides more control over the iterative EM algorithm used
%   by GMCLUSTER. Those input arguments are explained below.
%
%   'Start'  Method used to choose initial component parameters.
%            There are three choices:
%
%            'randSample'   Select K observations from X at random as the
%                           initial component means.  The mixing 
%                           proportions are uniform.  The initial
%                           covariance matrices for all clusters are
%                           diagonal, where the Jth element on the diagonal
%                           is the variance of X(:,J). This is the default.
%           'plus'          Select K observations from X as the initial
%                           component means by kmeans++ algorithm. Initial
%                           mixing proportions are uniform. Initial 
%                           covariance matrices for all components are
%                           diagonal, where the Jth element on the diagonal
%                           is the variance of X(:,J).
%
%             A structure array S containing the following fields:
%
%                           S.ComponentProportion:
%                           A 1-by-K vector specifying the mixing
%                           proportions of each component. The default
%                           is uniform.
%
%                           S.mu:
%                           A K-by-D matrix specifying the mean of each
%                           component.
%
%                           S.Sigma:
%                           An array specifying the covariance of each
%                           component. The size of Sigma is one of the
%                           following:
%                           * D-by-D-by-K array if there are no 
%                             restrictions on the form of covariance.  In
%                             this case, S.Sigma(:,:,J) is the covariance
%                             of component J.
%                           * 1-by-D-by-K array if the covariance matrices
%                             are restricted to be diagonal, but not
%                             restricted to be same across components. In
%                             this case, S.Sigma(:,:,J) contains the
%                             diagonal elements of the covariance of
%                             component J.
%                           * D-by-D matrix if the covariance matrices are
%                             restricted to be the same across clusters,
%                             but not restricted to be diagonal. In this
%                             case, S.Sigma is the pooled estimate of
%                             covariance.
%                           * 1-by-D vector if the covariance matrices are
%                             restricted to be diagonal and to be the same
%                             across clusters.  In this case, S.Sigma
%                             contains the diagonal elements of the pooled
%                             estimate of covariance.
%
%             A vector of length N containing the initial guess of the
%             component index for each point.
%
%   Reps   A positive integer giving the number of times to repeat
%                  the partitioning, each with a new set of parameters. The
%                  solution with the largest likelihood is returned. The
%                  default number of replicates is 1. A value larger than 1
%                  requires the 'randSample' start method.
%
%   CovType      1 if the covariance matrices are restricted to
%                  be diagonal; 2 otherwise.
%
%   SharedCov    True if all the covariance matrices are restricted to be
%                  the same (pooled estimate); false otherwise. The default
%                  is false.
%
%   Regv        A non-negative regularization number added to the
%                  diagonal of covariance matrices to make them positive-
%                  definite. The default is 0.
%
%   Options      Options structure for the iterative EM algorithm, as
%                  created by STATSET.  The following STATSET parameters
%                  are used:
%
%                     'Display'   Level of display output.  Choices are
%                                 'off' (the default), 'iter', and 'final'.
%                     'MaxIter'   Maximum number of iterations allowed.
%                                 Default is 100.
%                     'TolFun'    Positive number giving the termination
%                                 tolerance for the log-likelihood
%                                 function. The default is 1e-6.
%
%   See also FITGMDIST, KMEANS.

%   Copyright 2007-2014 The MathWorks, Inc.


[n,d]=size(X);
if isstruct(start)
    initPara=checkInitParam(start,k,d,CovType, SharedCov);
    start = 'parameter';
    if reps ~= 1
        error(message('stats:gmdistribution:ConflictReps'));
    end
elseif isvector(start) && isnumeric(start)
    if length(start) ~= n
        error(message('stats:gmdistribution:MisshapedInitIdx'));
    end
    if ~all(ismember(start, 1:k) )  || ~all(ismember(1:k,start))
        error(message('stats:gmdistribution:WrongInitIdx'));
    end
    initIdx = start;
    start='partition';
    if reps ~= 1
        error(message('stats:gmdistribution:ConflictReps'));
    end
elseif ischar(start) 
    if strncmpi(start,'randsample',length(start))
        start='randsample';
    elseif strncmpi(start,'plus',length(start))
        start='plus';
%     elseif strncmpi(start,'fullplus',length(start))
%         start='fullplus';
    else
        error(message('stats:gmdistribution:BadStart'));
    end
    
else
    error(message('stats:gmdistribution:BadStart'));
 end

max_ll =- inf;
S = [];
optimInfo = [];
illCondCnt = 0;

for t = 1:reps
    switch start
        case 'randsample'
            initPara = randInitParam(X,k, CovType, SharedCov,RegV);
        case 'plus'   % {'fullplus'}
             initPara = plusInitParam(X,k, CovType, SharedCov,RegV);
        case 'partition'
            initPara = partInitParam(X,k,CovType, SharedCov,RegV,initIdx);
    end
    if (  options.Display >1) && reps > 1 %final or iter
        fprintf('\n%s\n',getString(message('stats:gmdistribution:gmcluster_Repetition', t)));
    end

    % run Gaussian mixture clustering once.
    % At this point, the initial parameter should be given
    try
        [S0,ll0,  optimInfo0] = gmcluster_learn...
            (X, k, initPara,  CovType, SharedCov, RegV,options);
        if ~optimInfo0.Converged
                  
           if reps==1
                warning(message('stats:gmdistribution:FailedToConverge', options.MaxIter,k));
           else
                warning(message('stats:gmdistribution:FailedToConvergeReps', options.MaxIter, t,k));
           end
        end

        if options.Display > 1 % 'final' or 'iter'
              fprintf('%d iterations, log-likelihood = %g\n',optimInfo0.Iters,ll0);
        end

        if  ll0 > max_ll % keep the best one
            S = S0;
            max_ll = ll0;
            optimInfo = optimInfo0;
        end
    catch ME
        if reps == 1 || (~isequal(ME.identifier,'stats:gmdistribution:IllCondCov') && ...
                         ~isequal(ME.identifier,'stats:gmdistribution:IllCondCovIter'))
            rethrow(ME);
        else
            illCondCnt = illCondCnt + 1;
            warning(message('stats:gmdistribution:IllCondCov', t, k, ME.message( strfind( ME.message, sprintf( '\n' ) ) + 1:end )));

            if illCondCnt == reps
                m = message('stats:gmdistribution:IllCondCovAllReps');
                throwAsCaller(MException(m.Identifier,'%s',getString(m)));
            end
        end
    end

end %  reps

NlogL = -max_ll;

end %gmcluster function

%------------------------------------------------------------------
% run mixture of Gaussian clustering once
% At this point the initial parameters should be given
function [S,ll, optimInfo] = ...
    gmcluster_learn(X, k, initPara, CovType, SharedCov,regVal,options)

[~,d] = size(X);
%allocate memory
S = initPara;
ll_old = -inf;

optimInfo.Converged = false;
optimInfo.Iters=0;

dispfmt = '%6d\t%12g\n';

if options.Display > 2 % 'iter'
   fprintf('  iter\t    log-likelihood\n');
end


for iter = 1:options.MaxIter;
    %E-step
    %compute the posteriors

    try
        log_lh=wdensity(X,S.mu, S.Sigma, S.PComponents, SharedCov, CovType);
        [ll,post] = estep(log_lh);
    catch ME
        if ~isequal(ME.identifier,'stats:gmdistribution:wdensity:IllCondCov')
            rethrow(ME);
        else
            m = message('stats:gmdistribution:IllCondCovIter',iter);
            throwAsCaller(MException(m.Identifier,'%s',getString(m)));
        end
    end
    if options.Display > 2 %'iter'
        fprintf(dispfmt, iter, ll);
    end

    %check if it converges
    llDiff = ll-ll_old;
    if llDiff >= 0 && llDiff < options.TolFun *abs(ll)
        optimInfo.Converged=true;
        break;
    end
    ll_old = ll;

    % M step
    % update mu, Sigma, PComponents
    S.PComponents = sum(post, 1);
    if SharedCov %common covariance
        if CovType == 2  %full covariance
            S.Sigma = zeros(d,d);
            for j = 1:k
                S.mu(j,:) = post(:,j)' * X / S.PComponents(j);
                Xcentered = bsxfun(@minus, X, S.mu(j,:));
                Xcentered = bsxfun(@times,sqrt(post(:,j)),Xcentered);
                S.Sigma = S.Sigma + Xcentered'*Xcentered;
            end
            S.Sigma = S.Sigma/sum(S.PComponents) + regVal *eye(d);
        else %diagonal
            S.Sigma = zeros(1,d);
            for j = 1:k
                S.mu(j,:) = post(:,j)' * X / S.PComponents(j);
                Xcentered = bsxfun(@minus, X, S.mu(j,:));
                S.Sigma = S.Sigma + post(:,j)' *(Xcentered.^2);
            end
            S.Sigma = S.Sigma/sum(S.PComponents)+regVal;
        end
    else %different covariance
        for j = 1:k
            S.mu(j,:) = post(:,j)' * X / S.PComponents(j);
            Xcentered = bsxfun(@minus, X, S.mu(j,:));
            if CovType == 2
                Xcentered = bsxfun(@times,sqrt(post(:,j)),Xcentered);
                S.Sigma(:,:,j) = Xcentered'*Xcentered/S.PComponents(j)+ regVal * eye(d);
            else % diagonal covariance
                S.Sigma(:,:,j) = post(:,j)' *...
                    (Xcentered.^2) /S.PComponents(j) +regVal;
            end
        end
    end
    % normalize PComponents
    S.PComponents = S.PComponents/sum(S.PComponents);

end %end iter loop
optimInfo.Iters = iter;

end %function gmcluster_learn

%------------------------------------------------------------------
%check whether the initial parameters are valid
function initParam = checkInitParam(initParam,k,d, covtype, sharecov)
if  isfield(initParam, 'ComponentProportion')
   initParam.PComponents= initParam.ComponentProportion;
end

if isfield(initParam, 'PComponents') && ~isempty(initParam.PComponents)
    if  ~isvector(initParam.PComponents) || length(initParam.PComponents) ~= k
        error(message('stats:gmdistribution:MisshapedInitP'));
    elseif any(initParam.PComponents <= 0 )
        error(message('stats:gmdistribution:InvalidP'));
    elseif size(initParam.PComponents,1) ~= 1
        initParam.PComponents = initParam.PComponents';
    end
else
    initParam.PComponents = ones(1,k); %default initial mixing proportions be equal
end

%normalize the mixing proportions
initParam.PComponents = initParam.PComponents/sum (initParam.PComponents);

if isfield(initParam,'mu') && ~isempty(initParam.mu)
    if ~isequal(size(initParam.mu),[k,d])
        error(message('stats:gmdistribution:MisshapedInitMu'));
    end
else
    error(message('stats:gmdistribution:MissingInitMu'));
end

if isfield(initParam,'Sigma') && ~isempty(initParam.Sigma)
    if sharecov || k == 1  % shared covariance or only one component
        if covtype == 1 %diagonal covariance
            if ~isequal (size(initParam.Sigma), [1 d])
                error(message('stats:gmdistribution:MisshapedInitSingleCov'));
            elseif  min(initParam.Sigma) < max(initParam.Sigma) * eps
                error(message('stats:gmdistribution:BadSingleInitCov'));
            end
        else %full covariance
            if ~isequal( size(initParam.Sigma),[d d] )
                error(message('stats:gmdistribution:MisshapedInitSingleCov'));
            end
            [~,err] = cholcov(initParam.Sigma);
            if err ~= 0
                error(message('stats:gmdistribution:BadSingleInitCov'));
            end

        end
    else % different covariance and there are more than one cluster
        if covtype == 1 %diagonal covariance
            if ~isequal(size(initParam.Sigma), [1 d k])
                error(message('stats:gmdistribution:MisshapedInitCov'));
            end
            for j = 1:k
                %check whether the covariance matrix is positive definite
                if  min(initParam.Sigma(:,:,j)) < max(initParam.Sigma(:,:,j)) * eps
                    error(message('stats:gmdistribution:BadInitCov'));
                end
            end
        else % full covariance
            if ~isequal (size(initParam.Sigma),[d d k])
                error(message('stats:gmdistribution:MisshapedInitCov'));
            end
            for j = 1:k
                % Make sure Sigma is a valid covariance matrix
                %check for positive definite
                [~,err] = cholcov(initParam.Sigma(:,:,j));
                if err ~= 0
                    error(message('stats:gmdistribution:BadInitCov'));
                end
            end
        end

    end
else
    error(message('stats:gmdistribution:MissingInitCov'));
end

end %function checkInitParam

%------------------
%get initial parameters using random sample
function initPara = randInitParam(X,k, CovType, SharedCov,RegV)
[n,d] = size(X);

initPara.mu = X(randsample(n,k),:);
initPara.PComponents = ones(1,k)/k ;% equal mixing proportions
if CovType == 1 %diagonal covariance
    if SharedCov
        initPara.Sigma = var(X) + RegV;
    else
        initPara.Sigma = repmat(var(X) + RegV,[1,1,k]);
    end
else %full covariance
    if SharedCov
        initPara.Sigma = diag(var(X)) + RegV*eye(d);
    else
        initPara.Sigma = repmat(diag(var(X)) + RegV*eye(d),[1,1,k]);
    end
end

end %function randInitParam

%------------------
%get initial parameters using plus sample
function initPara = plusInitParam(X,k, CovType, SharedCov,RegV)

initPara.PComponents = ones(1,k)/k ;% equal mixing proportions

%if strcmp(plustype,'fullplus')
%plustype should be a input of this function if used. 
 %[~,d] = size(X); 
 %   initSigma = cov(X) + RegV*eye(d);    % full cov to start
%else  % diagonal cov to start
initVar  = var(X) + RegV;
initSigma = diag(initVar); 
%end

if CovType == 1 %diagonal covariance
    Sigma = initVar;
else %full covariance matrix
    Sigma = initSigma;
end
if SharedCov
    initPara.Sigma = Sigma;
else
    initPara.Sigma = repmat(Sigma,[1,1,k]);
end

% Select the first seed by sampling uniformly at random
index = zeros(k,1);
[C(1,:), index(1)] = datasample(X,1);
                
% Select the rest of the seeds by a probabilistic model
for ii = 2:k
    sampleProbability = min(distfun(X , C(1:ii-1,:),initSigma),[],2);
    denominator = sum(sampleProbability);
    if denominator==0 || denominator==Inf
        C(ii:k,:) = datasample(X,k-ii+1,1,'Replace',false);
        break;
    end
    sampleProbability = sampleProbability/denominator;
                    
    [C(ii,:), index(ii)] = datasample(X,1,1,'Replace',false,...
        'Weights',sampleProbability);
end
initPara.mu = C;
end %function plusInitParam

function D = distfun(X, C, sigma)
n = size(X,1);
D = zeros(n,size(C,1));
nComponents = size(C,1);
for i = 1:nComponents
    delta = X-C(repmat(i,n,1),:);
    D(:,i) = sum(delta/sigma.*delta,2);
end
      
end % distance function


%---------------------------------------------------------------------
%get initial parameters when initial partition is provided
function initPara = partInitParam(X,k,CovType, SharedCov,RegV,initIdx)
[n,d]=size(X);
initPara.mu = zeros(k,d);
initPara.PComponents = zeros(1,k);

% compute initial mu, Sigma, mixing proportions
initPara.PComponents = histc(initIdx,1:k); %unnormalized mixing proportions
if SharedCov
    if CovType == 2 %full covariance
        initPara.Sigma = zeros(d,d);
        for j = 1:k
            X0 = X(initIdx == j,:);
            initPara.mu(j,:) = mean(X0);
            X0 = bsxfun(@minus,X0,initPara.mu(j,:));
            initPara.Sigma = initPara.Sigma + X0' * X0;
        end
        initPara.Sigma = initPara.Sigma/n + RegV * eye(d) ;
    else %diagonal covariance
        initPara.Sigma = zeros(1,d);
        for j = 1:k
            X0=X(initIdx ==j,:);
            initPara.mu(j,:) = mean(X0);
            X0=bsxfun(@minus,X0,initPara.mu(j,:));
            initPara.Sigma = initPara.Sigma + sum(X0.^2,1);
        end
        initPara.Sigma = initPara.Sigma/n + RegV;
    end
else %different covariance
    if CovType == 2 %%full covariance
        initPara.Sigma=zeros(d,d,k);
        for j = 1:k
            X0 = X(initIdx == j,:);
            initPara.mu(j,:) = mean(X0);
            X0 = bsxfun(@minus,X0,initPara.mu(j,:));
            initPara.Sigma(:,:,j) = X0' * X0/initPara.PComponents(j)+ RegV* eye(d);
        end
    else % diagonal covariance
        initPara.Sigma = zeros(1,d,k);
        for j = 1:k
            X0 = X(initIdx == j,:);
            initPara.mu(j,:) = mean(X0);
            X0 = bsxfun(@minus,X0,initPara.mu(j,:));
            initPara.Sigma(:,:,j) = sum(X0.^2,1)/initPara.PComponents(j) + RegV;
        end
    end
end
initPara.PComponents = initPara.PComponents/n;

end %function getInitParam


