%REGOPTC Optimise regularisation and complexity parameters by crossvalidation
%
%		[W,PARS] = REGOPTC(A,CLASSF,PARS,DEFS,NPAR,PAR_MIN_MAX,TESTFUN,REALINT)
%
% INPUT
%   A       Dataset, training set
%   CLASSF  String containing the name of the classifier routine.
%   PARS    Cell array with parameters for CLASSF
%   DEFS    Defaults for PARS
%   NPAR    Index in PARS of parameters to be optimised
%   PAR_MIN_MAX Minimum and maximum values of the search interval for
%           the parameters to be optimised
%   TESTFUN Criterion function to be minimised, default TESTC
%   REALINT 0/1 vector, indicating for every parameter in PARS whether
%           it is real (1) or integer (0). Default: all real.
%
% OUTPUT
%   W       Best classifier, trained by A
%   PARS    Resulting parameter vector
%
% DESCRIPTION
% This routine is used inside classifiers and mappings to optimise a
% regularisation or complexity parameter. Using cross-validation the
% performance of the classifier is estimated using TESTFUN (e.g. TESTC).
% FMINBND is used for the optimisation. Only the parameters in PARS that are
% set to NaN are optimised. For the other ones the given values are used in
% the internal calls to CLASSF in REGOPTC. In case mulitple parameters are set
% to NaN they are optimised in the order supplied by NPAR. 
%
% The final parameters PARS can also be retrieved by GETOPT_PARS. This is
% useful if W is optimised inside training a classifier that does not
% return these parameters in the output.
%
% For examples of usage inside a classifier see LDC and SVC. Consequently
% LDC can be called as in the below example.
%
% Some globals are used to specify the optimisation. Users may change them
% by PRGLOBAL. See the <a href="http://www.37steps.com/faq/faq-regopt/">FAQ</a> on this topic.
%
% EXAMPLE
% A = gendatd([30 30],50);
% W = ldc(A,0,NaN); % set first reg par to 0 and optimise second.
% getopt_pars       % retrieve optimal paameter set
%
% SEE ALSO (<a href="http://37steps.com/prtools">PRTools Guide</a>)
% DATASETS, MAPPINGS, PRCROSSVAL, TESTC, GETOPT_PARS, PRGLOBAL

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function [w,varargout] = regoptc(a,classf,parms,defs,regparnum,regparmin_max,testfunc,realint)

	global REGOPT_NFOLDS REGOPT_REPS REGOPT_ITERMAX REGOPT_ITER ...
         REGOPT_OPTCRIT REGOPT_PARS STOPPED_BY_PRTIME
         
  STOPPED_BY_PRTIME = false;
         
	if isempty(REGOPT_NFOLDS),  REGOPT_NFOLDS = 2; end
	if isempty(REGOPT_REPS),    REGOPT_REPS = 'DPS'; end
	if isempty(REGOPT_ITERMAX), REGOPT_ITERMAX = 20; end
	REGOPT_OPTCRIT = inf;
	REGOPT_PARS = [];
  
  if nargin == 0 % needed to set globals in prglobal
    return
  end

	isdataset(a);
	isuntrained(feval(classf,[],parms{:}));
	if nargin < 8, realint = ones(1,length(parms)); end
	if nargin < 7 || isempty(testfunc)
    if isempty(a,'prior') || any(classsizes(a) < 3)
      testfunc = testd;
    else
      testfunc = testc([],'soft');
    end
  end
% 	if (length(parms) ~= length(defs)) || (length(parms) < max(regparnum)) || ...
% 			(length(parms) ~= size(regparmin_max,1)) || (length(regparnum) ~= length(realint)) || ...
% 			(size(regparmin_max,2) ~= 2)
% 		error('Some parameters have wrong size')
% 	end
	if (length(parms) ~= length(defs)) || (length(parms) < max(regparnum)) || ...
			(length(parms) ~= size(regparmin_max,1)) || (length(parms) ~= length(realint)) || ...
			(size(regparmin_max,2) ~= 2)
		error('Some parameters have wrong size')
	end

	J = [];
	K = false(1,length(parms));
	for j=1:length(parms)
		if ~isempty(parms{j}) && ~ismapping(parms{j}) && ~isstruct(parms{j}) && isnan(parms{j})
			J = [J j];
			K(j) = 1;   % parameters to be optimised
		end
	end
	parms(J) = defs(J);  % store defaults (needed in case of optimal parameters)
	matwarn = warning;
	warning off
%	prwarn = prwarning;
%	prwarning(0);
  N = find(K);
  rsize = numel(N);
  t = sprintf('Optimisation of %i parameterss: ',rsize);
	prwaitbar(rsize,t);
	for j=1:rsize	
		prwaitbar(rsize,j,[t num2str(j)]);
  	n = N(j);
    regparmin = regparmin_max(n,1);
    regparmax = regparmin_max(n,2);
    if regparmin > 0 && regparmax > 0 && realint(n) % if interval positive and real
      setlog = 1;                             % better to use logarithmic scaling
      regparmin = log(regparmin);
      regparmax = log(regparmax);
    else
      setlog = 0;
    end
    REGOPT_ITER = 0;
    prwaitbar(REGOPT_ITERMAX+1,'Parameter optimisation');  
    tic;
    if realint(n) == 1
      if isoctave
        fun = @(x)evalregcrit(x,classf,a,parms,n,setlog,REGOPT_NFOLDS,REGOPT_REPS,testfunc,1);
        regpar = ofminbnd(fun,regparmin,regparmax, ...
          optimset('Display','off','maxiter',REGOPT_ITERMAX,'TolFun',1e-10));
      else
        regpar = rfminbnd(@evalregcrit,regparmin,regparmax, ...
          optimset('Display','off','maxiter',REGOPT_ITERMAX), ...
          classf,a,parms,n,setlog,REGOPT_NFOLDS,REGOPT_REPS,testfunc,1);
      end
    else
        regpar = nfminbnd(@evalregcrit,regparmin,regparmax,REGOPT_ITERMAX, ...
          classf,a,parms,n,setlog,REGOPT_NFOLDS,REGOPT_REPS,testfunc,0);
    end
    if STOPPED_BY_PRTIME
      prwarning(2,'Regularisation optimisation stopped by PRTIME')
    end
    prwaitbar(0)
    if setlog
      parms{n} = exp(regpar);
    else
      parms{n} = regpar;
    end
	end
	prwaitbar(0);
	varargout = cell(1,nargout-1);
	[w,varargout{:}] = feval(classf,a,parms{:});
	REGOPT_PARS = parms;
	warning(matwarn);
%	prwarning(prwarn);

return

function regcrit = evalregcrit(regpar,classf,a,parms,regparnum, ...
	setlog,nfolds,reps,testfunc,realint)

	global REGOPT_ITER REGOPT_OPTCRIT REGOPT_ITERMAX PREV_CRIT
   
	REGOPT_ITER = REGOPT_ITER+1;
	
	prwaitbar(REGOPT_ITERMAX+1,REGOPT_ITER);
	
	if setlog
		parms{regparnum} = exp(regpar);
	else
		parms{regparnum} =regpar;
	end
			
	w = feval(classf,[],parms{:});
	randstate = randreset(1);
	regcrit = prcrossval(a,w,nfolds,reps,testfunc); % use soft error as criterion (more smooth)
	randreset(randstate);
  
	REGOPT_OPTCRIT = min(mean(regcrit),REGOPT_OPTCRIT);
  
    
return
