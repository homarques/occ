%WEAKC Weak Classifier
%
%   [W,V] = WEAKC(A,ALF,N,CLASSF)
%   [W,V] = A*WEAKC(ALF,N,CLASSF)
%    VC   = WEAKC(A,ALF,N,CLASSF,1)
%
% INPUT
%   A       Dataset
%   ALF     Fraction or number of objects to be used for training, see
%           GENDAT. Default: one object per class. For integer ALF, ALF
%           objects per class are generated. Default 1;
%   N       Number of classifiers to be generated, default 1.
%   CLASSF  untrained classifier, default NMC
%
% OUTPUT
%   W       Best classifier over ITER runs
%   V       Cell array of all classifiers
%           Use VC = stacked(V) for combining
%   VC      Combined set of classifiers
%
% DESCRIPTION
% WEAKC uses subsampled versions of A for training. Testing is done
% on the entire training set A. The best classifier is returned in W.
% VC combines all classifiers as a stacked combiner in VC.
%
% This routine offers several ways to construct a wea classifier. The
% larger ALF, the larger ITER or the more complex CLASSF, the less weak the
% resulting classifier W will be. The combined classifier VC is for large
% values of N not a weak classifier.
%
% For multi-class problem results may be improved in some cases, e.g. 
% for small N and / or simple CLASSF, by W = A*(WEKAC*QDC([],[],1e-6))
%
% SEE ALSO (<a href="http://37steps.com/prtools">PRTools Guide</a>)
% MAPPINGS, DATASETS, NMC, GENDAT, STACKED

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function [w,v] = weakc(varargin)
	
%               INITIALISATION

	argin = shiftargin(varargin,'scalar',1);
  argin = setdefaults(argin,[],1,1,0,0);
  
  if mapping_task(argin,'definition')
    w = define_mapping(argin,'untrained','Weak');
    
%                 TRAINING

  elseif mapping_task(argin,'training')			% Train a mapping.
  
    [a,n,iter,r,s] = deal(argin{:});
    
    % remove too small classes, escape in case no two classes are left
    [a,m,k,c,lablist,L,w] = cleandset(a,1); 
    if ~isempty(w), v = {w}; return; end
    
    if (n >= 1 ) && (n > min(classsizes(a)))
      n = min(classsizes(a));
      prwarning(3,['Training size too small. Subsample rate replaced by ', num2str(n)])
    end
    if isscalar(n) && n >= 1
      n = n*ones(1,getsize(a,3));
    end
    v = cell(1,iter);
    emin = 1;
    
    for it = 1:iter              % Loop
      b = gendat(a,n);           % subsample training set
      if ~ismapping(r)           % select classifier and train
        if r == 0                % be consistent with old classfier selection
          ww = nmc(b); 
        elseif r == 1
          ww = fisherc(b); 
        elseif r == 2
          ww = udc(b);
        elseif r == 3
          ww = qdc(b);
        else
          error('Illegal classifier requested')
        end
      else
        if ~isuntrained(r)
          error('Input classifier should be untrained')
        end
        ww = b*r;
      end
      e = a*ww*testc;
      ww = allclass(ww,lablist,L);
      v{it} = ww;                 % store all classifiers in v
                                  % select best classifier and store in w
      if e < emin
        emin = e;
        w = ww;
      end
    end

    if s == 1
      w = stacked(v);
    end
    
  end

return