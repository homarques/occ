%LOGMLC Logistic Multi-Class Linear Classifier (Multinomial Logit)
% 
%   W = LOGMLC(A)
%   W = LOGMLC(A, LABLIST_NAMES)
% 
% INPUT
%   A              Dataset
%   LABLISTNAMES   The character array of additional labelings which priors
%                  (along with the current labeling prior) have to be taken 
%                  into account to compute object weights. It is useful if 
%                  there are object subgroups which abundances in the 
%                  (optional; default: '') 
%
% OUTPUT
%   W   Logistic Multi-Class Linear Classifier 
%
% DESCRIPTION  
% Computation of the linear classifier for the dataset A by maximizing the
% likelihood of the assumed posterior probalility model:
%
%  p(c|x) = exp(w_c'x + b_c)/(exp(w_1'x + b_1) + exp(w_2'x + b_2) + ...)
%
% Differences from the LOGLC:
% 1) Genuine multi-class classification. All weights are optimized simultaneously.
% 2) More careful Newtonian optimization procedure.
% 3) The use of Cholesky factorization instead of pinv for Hessian inversion.
%
%  SEE ALSO (<a href="http://37steps.com/prtools">PRTools Guide</a>)
%  MAPPINGS, LOGLC

% Copyright: S. Verzakov, s.verzakov@gmail.com

function [w, res] = logmlc(a, options)
  
  prtrace(mfilename);
  
  if nargin < 2
    options = [];
  end
  
  % parameters
  def_options.mode = 'full'; % score_scaling
  def_options.acc = 1e-6;
  def_options.hessian_reg = 1e-3;
  def_options.wahba_reg = 1e-7;  
  def_options.platt_reg = false;  
  def_options.alpha = 0.3;
  def_options.beta = 0.5;
  def_options.t0 = 1;
  def_options.t1 = 2^(-32);
  def_options.reweighing_lablist_names = '';
  def_options.fid = [];
  
  def_options_scale = def_options;
  def_options_scale.mode = 'score_scaling'; % score_scaling
  def_options_scale.wahba_reg = 0;  
  def_options_scale.platt_reg = true;  
    
  if isfield(options, 'mode') && strcmpi(options.mode, 'score_scaling')
    options = updstruct(def_options_scale, options);  
  else
    options = updstruct(def_options, options);  
  end
  
  % No input data, return an untrained classifier.
	if (nargin == 0) || (isempty(a))
    try
      is_prt5 = prversion >= 5;
    catch  %#ok<CTCH>
      is_prt5 = false;  
    end
    if is_prt5
      w = prmapping(mfilename, {options}); 
    else
      w = mapping(mfilename, options);
    end
    w = setname(w, 'Logistic Multi-Class Linear Classifier');
	  return
  end


  % we work only with crisp labels
  islabtype(a, 'crisp');
  % is dataset / datafile 	for the number of objects
  [a,~,~,~,lablist,L,w] = cleandset(a,1); 
  if ~isempty(w), return; end
  %isvaldfile(a, 1, 2); % at least 1 object per class, 2 classes
  % convert datafile to dataset if needed and possible
  a = testdatasize(a); 
  %fid = []; % Progress messages default destination
	
  % reading dataset info
  nlab = getnlab(a);
  prior = getprior(a);
  n = classsizes(a);

  % nu is the weight of the individual object
  % according to priors
  nu = prior(:) ./ n(:);    
  nu = nu(nlab);
  
  % reweighing objects inside classes according to 
  % additional labelling
  if ~isempty(options.reweighing_lablist_names)
    options.reweighing_lablist_names = cellstr( ...
      options.reweighing_lablist_names ...
    );
    cur_lablist_numb = curlablist(a);
    for i=1:size(options.reweighing_lablist_names, 1)
      a = remclass(changelablist(a, options.reweighing_lablist_names{i}));
      warn_level = prwarning;
      prwarning(0);
      grp_prior = getprior(a);
      prwarning(warn_level);
      n_i = classsizes(a);
      nu_i = grp_prior(:) ./ n_i(:);
      nlab_i = getnlab(a);
      nu_i = nu_i(nlab_i);
      nu = nu .* nu_i;
    end
    nu = nu / sum(nu);
    a = changelablist(a, cur_lablist_numb);
    clear n_i nu_i nlab_i lablist_names warn_level grp_prior
  end  
  
  
  switch options.mode 
    case 'full'
      [w, res] = TrainFullLogMLC(nu, nlab, a, options);
    case 'score_scaling'
      [w, res] = TrainScoreScaling(nu, nlab, a, options);
  end
  w = allclass(w,lablist,L);
  
  return

function [w, res] = TrainFullLogMLC(nu, nlab, a, options)    
  % getting dataset sizes
  [m, k, c] = getsize(a);
    
  % linear logistic classifier is scale, rotation, and reflection invariant
  % but we apply autoscaling for the sake of numerical stability
  v = scalem(a, 'variance');
  a = a * v;

  % extracting data
  X = +a;
  
  % excluding all constant features
  indf = find(var(X, 0, 1) > 0)';
  res.num_non_const_feat = numel(indf);
  % adding one constant feature responsible for bias term
  X = [X(:, indf), ones(m, 1)];
  indf = [indf; (k+1)];
  
  % reducing dimensionality
  % X = U * S * V'
  % keeping only scores which correspond
  % to singular values > m*eps(S1),
  % m is the number of rows in X  
  [U, S, V] = svd(X, 'econ');
  clear X
  S = diag(S);
  tolX = m * eps(S(1));
  r = nnz(S > tolX);
  U = U(:, 1:r);
  S = S(1:r);
  V = V(:, 1:r);
  % subtracting 1 because r contains also bias term
  % which is orthogonal to all scaled features  
  
  % rescaling Wahba's regularization parameter
  % to the number of degrees of freedom
  options.wahba_reg_scl = options.wahba_reg / (r*(c-1));
  
  % only c - 1 weight vectors are optimised: 
  % there are only r*(c-1) degrees of freedom, so we put W(:,c) to 0 
  W = zeros(r, c-1);
  P = repmat(1/c, [m c]);
  indp = sub2ind([m c], (1:m)', nlab);
  nu_mat = sparse(1:m, nlab, nu, m, c, m);
  if options.platt_reg
	% Ensuring overlap by using Bayesian weights:
	% if the real object weight is 1 then it becomes (mc+1)/(mc+c), 
	% also (c-1) fake objects with weights 1/(mc+c) are added
    mc = m * accumarray(nlab, nu, [c, 1]);
    Gamma = repmat(1./(mc+c), [1 c]);
    Gamma = Gamma + diag(mc./(mc+c));
  end
  
% % computing L if W ~= 0 
% if options.platt_reg
%    L = sum(sum((nu_mat'*log(P+realmin)) .* Gamma));
%    L = nu' * sum(Gamma(nlab, :) .* log(P+realmin), 2);
%  else
%    L = nu' * log(P(indp) + realmin); 
%  end 
%  if options.wahba_reg_scl > 0
%    L = L - 0.5*options.wahba_reg_scl*sum(sum(W.^2));
%  end
  
  % W == 0, so we can compute L now very easily
  L = sum(nu * log(1/c + realmin));
  L0 = L;
  
  % fixed part of gradient:
  % centers of gravity for each class,
  % mixing them, if Platt's regularization is used
  if options.platt_reg   
    G0 = U' * nu_mat * Gamma(:, 1:end-1);
  else
    G0 = U' * nu_mat(:, 1:end-1);
  end
  
  % preallocating gradient
  G = zeros(r, c-1);

  % preallocating negative Hessian
  D = zeros(numel(G));
  indd = sub2ind(size(D), 1:size(D,1), 1:size(D,2))';

  prprogress(options.fid, 'logmlc: full mode (multinomial logit)\n');
  t = 0;
  iter = 0; starttime = clock;
  runtime = 0;
  while true && runtime < prtime
    % computing gradient and negative Hessian 
    for i = 1:c-1
      indr = (1:r) + r*(i-1);
      indc = indr;

      Ui = bsxfun(@times, U, nu.*P(:, i)); 
      G(:, i) = G0(:, i) - sum(Ui.', 2);
      Uj = bsxfun(@times, U, 1-P(:, i)); 
      D(indr, indc) = Ui' * Uj;

      for j = i+1:c-1
        indc = (1:r) + r*(j-1); 
        Uj = bsxfun(@times, U, P(:, j));         
        D(indr, indc) = -Ui' * Uj;
        % not needed, because we do Cholesky 
        % factorization wich looks only at diag and up triangle
        %D(indc, indr) = D(indr, indc).';
      end
    end
    
    % regularization, necessary if classes do not overlap
    if options.wahba_reg_scl > 0
      G = G - options.wahba_reg_scl * W;
      D(indd) = D(indd) + options.wahba_reg_scl;
    end
    
    % extra symmitrization should not be done, 
    % because lower triangel is not fully filled:
    % it is not needed for Cholesky factorization
    %D = min(D, D.');
    
    % computing the direction in Newton optimization:
    % dW = D^(-1) * G
    try
      R = chol(D);
    catch me
      prwarning(1, '%s', me.message);
      prwarning(1, '%s', 'trying regularization');
      R = chol( ...
        (1-options.hessian_reg)*D + options.hessian_reg*diag(diag(D)) ...
      );
    end
    dW = reshape(R\(R.'\G(:)), [r (c-1)]);    

    % crit = 1/2 grad' H^(-1) grad 
    crit = 0.5 * sum(sum(G.*dW));
    prprogress( ...
      options.fid, ...
     'iter %.3d, crit %5.2e, t %5.2e, llh %5.2e\n', ...
      iter, crit, t, L ...
    );      

    if crit <= options.acc
      break;
    end

    iter = iter + 1;      

    % Newton's optimization step using backtracking line search
    W_old = W;
    L_old = L;
    t = options.t0;
    while true 
      W = W_old + t*dW;
      P = boltzpm([U * W, zeros(m,1)]);    
      if options.platt_reg
        L = sum(sum((nu_mat'*log(P+realmin)) .* Gamma));
      else
        L = nu' * log(P(indp)+realmin);
      end
      if options.wahba_reg_scl > 0
        L = L - 0.5*options.wahba_reg_scl*sum(sum(W.^2));
      end
      L_lb = L_old + options.alpha*t*(2*crit);
      if L <= L_lb
        t = options.beta * t;
        if t < options.t1
          break;
        end
      else
        break;
      end
    end
    
    if L <= L_lb
      error('Cannot converge, backtracking line search failed.');
    end;
    runtime = etime(clock,starttime);
  end
  if runtime > prtime
    prwarning(2,['logmlc updating stopped by PRTIME after ' num2str(iter) ' iterations.']);
  end
  
  % projecting weights back to the original space
  W = bsxfun(@rdivide, V, S.') * W;
  w = zeros(k + 1, c);
  w(indf, 1:c-1) = W;
  
  % recalibrating weights (which is not necessary): 
  % instead of w(:, c) == 0, making sum (w, 2) == 0
  %w = bsxfun(@minus, w, mean(w, 2));

  % collecting all mappings: preprocessing, trained weights, 
  % boltzmann probabilities
  lablist = getlablist(a);
  featlist = getfeatlab(a);
  w = v * affine(w(1:end-1, :), w(end, :), featlist, lablist, k, c);
  w = w * boltzpm; 
    
  w = setout_conv(w, 0);
  w = setname(w, 'LOGMLC: full mode (multinomial logit)');
  
  res.options = options;  
  [res.m, res.k, res.c] = deal(m, k, c);  
  res.num_indep_feat = r-1;
  res.L_start = L0;
  res.L_end = L;
  res.crit = crit;
  res.num_iter = iter;
  res = updstruct(res, +w{1});  
  res.lablist_in = featlist;
  res.lablist_out = lablist;
  res.lablist_trn = lablist;
  res = orderfields(res);  
  
  return
  
function [w, res] = TrainScoreScaling(nu, nlab, a, options)
  
  % getting  dataset sizes
  [m, k, c] = getsize(a); 
  if k < c
    error('The number of score features is less the number of classes');    
  end
  
  % no scaling for options.wahba_reg, use it as is
  options.wahba_reg_scl = options.wahba_reg;
    
  lablist = getlablist(a);
  featlab = getfeatlab(a);
  % indices of labs in features
  labidx = renumlab(lablist, featlab); 
  if any(~labidx)
    error('Scores for some classes are absent');
  end

  % extracting sores corresponding to the label class   
  % fnlab is the number of the features, which correspond to the 
  % object label class, idx is a liner index of such scores in a
  fnlab = labidx(nlab);
  indx = sub2ind([m k], (1:m)', fnlab);
 
  X = + a;
    
  s = 1e-10;
  P = boltzpm(s*X);
  if options.platt_reg
    nu_mat = sparse(1:m, fnlab, nu, m, k, m);      
    mc = m*accumarray(fnlab, nu, [k, 1]);
    Gamma = repmat(1./(mc+k), [1 k]);
    Gamma = Gamma + diag(mc./(mc+k));
    %L = nu' * sum(Gamma(fnlab, :) .* log(P+realmin), 2);
    L = sum(sum(nu_mat' * log(P+realmin) .* Gamma));
  else
    L = nu' * log(P(indx)+realmin);
  end
  
  if options.wahba_reg_scl > 0
    L = L - 0.5*options.wahba_reg_scl*s^2;
  end
  L0 = L;

  % fixed part of gradient avarage score of correct class
  if options.platt_reg
    %G0 = nu' * sum(Gamma(fnlab, :) .* X, 2);
    G0 = sum(sum(nu_mat' * X .* Gamma));    
  else
    G0 = nu' * X(indx);    
  end
  
  prprogress(options.fid, 'logmlc: score scaling mode\n');
  t = 0;
  iter = 0;
  iter = 0; starttime = clock;
  runtime = 0;
  while true && runtime < prtime
    % computing gradient 
    % and negative second derivative
    G = G0 - nu'*sum(X.*P, 2);
    D = nu'* sum((bsxfun(@minus, X, sum((X.*P), 2)).^2).*P, 2);
        
    % regularization, necessary if classes do not overlap
    if options.wahba_reg_scl > 0
      G = G - options.wahba_reg_scl*s;
      D = D + options.wahba_reg_scl;
    end
    
    ds = G/D;    

    % crit = 1/2 grad' H^(-1) grad 
    crit = 0.5 * G*ds;
    prprogress( ...
      options.fid, ...
     'iter %.3d, crit %5.2e, t %5.2e, s %5.2e, llh %5.2e\n', ...
      iter, crit, t, s, L ...
    );      

    if crit <= options.acc
      break;
    end

    iter = iter + 1;      

    % Newton's optimization step using backtracking line search
    s_old = s;
    L_old = L;
    t = options.t0;
    while true 
      s = s_old + t*ds;
      P = boltzpm(s*X);
      if options.platt_reg
        %L = nu' * sum(Gamma(fnlab, :).* log(P+realmin), 2);
        L = sum(sum(nu_mat' * log(P+realmin) .* Gamma));        
      else
        L = nu' * log(P(indx)+realmin);
      end
      
      if options.wahba_reg_scl > 0
        L = L - 0.5*options.wahba_reg_scl*s^2;
      end

      L_lb = L_old + options.alpha*t*(2*crit);
      if L <= L_lb
        t = options.beta * t;
        if t < options.t1
          break;
        end
      else
        break;
      end
    end
    
    if L <= L_lb
      error('Cannot converge, backtracking line search failed.');
    end;
    runtime = etime(clock,starttime);
  end
  if runtime > prtime
    prwarning(2,['logmlc updating stopped by PRTIME after ' num2str(iter) ' iterations.']);
  end
      
  w = affine(repmat(s, [1, k]), zeros(1, k), featlab, featlab, k, k);
  w = w * boltzpm;
  w = setout_conv(w, 0);
  w = setname(w, 'LOGMLC: score scaling mode');
  
  res.options = options;	
  [res.m, res.k, res.c] = deal(m, k, c);  
  res.L_start = L0;  
  res.L_end = L;
  res.crit = crit;
  res.num_iter = iter;
  res.s = s;
  res.lablist_in = featlab;
  res.lablist_out = featlab;
  res.lablist_trn = lablist;  
  res = orderfields(res);
    
  return



