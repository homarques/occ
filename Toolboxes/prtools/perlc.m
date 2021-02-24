% PERLC - Trainable linear perceptron classifier
% 
%   W = PERLC(A,MAXITER,ETA,W_INI,TYPE)
%   W = A*PERLC([],MAXITER,ETA,W_INI,TYPE)
%   W = A*PERLC(MAXITER,ETA,W_INI,TYPE)
%
% INPUT
%   A        Training dataset
%   MAXITER  Maximum number of iterations (default 1000)
%   ETA      Learning rate (default 0.1)
%   W_INI    Initial weights, as affine mapping, e.g W_INI = NMC(A)
%            (default: random initialisation)
%   TYPE     'batch': update by batch processing (default)
%            'seq'  : update sequentially
%
% OUTPUT
%   W        Linear perceptron classifier mapping
%
% DESCRIPTION
% Outputs a perceptron W trained on dataset A using learning rate ETA for
% a maximum of MAXITER iterations (or until convergence). 
%
% If ETA is NaN it is optimised by REGOPTC.
%
% The resulting linear base-classifiers are combined by the maximum
% confidence rule. A better combiner usually will be QDC, e.g.
% W = A*(PERLC*QDC([],[],1e-6)).
%
% SEE ALSO (<a href="http://37steps.com/prtools">PRTools Guide</a>)
% DATASETS, MAPPINGS, NMC, FISHERC, BPXNC, LMNC, REGOPTC, FISHERCC

% Copyright: D. de Ridder, R.P.W. Duin, r.p.w.duin@37steps.com
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function w = perlc (varargin)
  
	mapname = 'Perceptron';
  argin = shiftargin(varargin,'scalar');
  argin = setdefaults(argin,[],1000,0.1,[],'batch');
  
  if mapping_task(argin,'definition')
    w = define_mapping(argin,'untrained',mapname);
    
  elseif mapping_task(argin,'training')			% Train a mapping.
  
    [a, maxiter, eta, w_ini, type] = deal(argin{:});
	
    if isnan(eta)    % optimise regularisation parameter
      defs = {1000,0.1,[],'batch'};
      parmin_max = [0,0;1e-6,0.9;0,0;0,0];
      w = regoptc(a,mfilename,{maxiter, eta, w_ini, type},defs,[2],parmin_max,[],1);
      return
    end
    islabtype(a,'crisp');
    
    % remove too small classes, escape in case no two classes are left
    [a,m,k,c,lablist,L,w] = cleandset(a,1); 
    if ~isempty(w), return; end
    nlab = getnlab(a);

    % PERLC is basically a 2-class classifier. More classes are
    % handled by mclassc.

    if c == 2   % two-class classifier

      ws = scalem(a,'variance');
      % Add a column of 1's for the bias term.
      Y = [+(a*ws) ones(m,1)]; 

      % Initialise the WEIGHTS with a small random uniform distribution,
      % or with the specified affine mapping.
      if isempty(w_ini)
        weights = 0.02*(rand(k+1,c)-0.5);
      else
        % something wrong here
        isaffine(w_ini);
        ww=affine(setout_conv(w_ini,0),ws);
        %weights = [w_ini.data.rot;w_ini.data.offset];
        weights = [ww.data.rot;ww.data.offset];
      end

      converged = 0; iter = 0;
      s = sprintf('perlc, %i iterations: ',maxiter);
      prwaitbar(maxiter,s,m*k>100000);
      starttime = clock;
      runtime = 0;
      while (~converged) && runtime < prtime
        
        % Find the maximum output for each sample.
        [maxw,ind] = max((Y*weights)');

        changed = 0;
        if (strcmp(type,'batch'))
          % Update for all incorrectly classified samples simultaneously.
          changed = 0;
          for i = 1:m
            if (ind(i) ~= nlab(i))
              weights(:,nlab(i)) = weights(:,nlab(i)) + eta*Y(i,:)';
              weights(:,ind(i))  = weights(:,ind(i))  - eta*Y(i,:)';
              changed = 1;
            end;
          end;
          iter = iter+1;
        else
          % update for the worst classified object only
          J = find(ind' ~= nlab);
          if ~isempty(J)
            [dummy,imax] = min(maxw(J)); i = J(imax);
            weights(:,nlab(i)) = weights(:,nlab(i)) + eta*Y(i,:)';
            weights(:,ind(i))  = weights(:,ind(i))  - eta*Y(i,:)';
            iter = iter+1;
            changed = 1;
          end;
        end
        % Continue until things stay the same or until MAXITER iterations.
        converged = (~changed || iter >= maxiter);
        prwaitbar(maxiter,iter,[s int2str(iter)]);
        runtime = etime(clock,starttime);

      end
      if runtime >= prtime
        prwarning(2,'Perceptron training stopped by PRTIME after %i iterations',iter);
      end
      %disp(iter)
      prwaitbar(0);

      % Build the classifier
      w = ws*affine(weights(1:k,:),weights(k+1,:),a);
      w = cnormc(w,a);
      w = setlabels(w,getlablist(a));
      w = setname(w,mapname);

    else   % multi-class classifier, combine one-against-rest classifiers

      w = prmapping(mfilename,{maxiter,eta,w_ini});
      w = mclassc(a,w); 
      w = allclass(w,lablist,L);     % complete classifier with missing classes
      w = setname(w,mapname);

    end	
    
  end
		
return
