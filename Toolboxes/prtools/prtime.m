%PRTIME Set/get size of maximum run times of some optimisations
% 
%   N = PRTIME(N)
%
%   N : The desired/retrieved maximum run time in seconds of optimisations.
%       Initially N = 10.
% 
% DESCRIPTION
% Some routines like the neural network classifiers NEURC, LMNC and BPXNC,
% and also ADABOOSTC, EMCLUST and the Parzen density estimators execute an
% optimisation loop until stability or for a maximum number of iterations. 
% Sometimes this takes too much time and early stopping is desired. 
% By PRTIME a global value is set or retrieved that controls the maximum
% time spent by the optimisation loop.
%
% PRTIME can temporarily be switched off by T = PRTIME(INF) and after some
% statements restarted by PRTIME(T). See OVERTIME for usage.
%
% On most places a PRWARNING level 2 message is generated when execution is
% stopped by PRTIME. It does not make much sense to have N < 1, as many
% routines have an overhead in the order of a second.
%
% SEE ALSO (<a href="http://37steps.com/prtools">PRTools Guide</a>)
% PRGLOBAL, LMNC, BPXNC, EMCLUST, PRWARNING, OVERTIME

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com

function n_out = prtime(n_in)

	persistent GLOBALPRTIME;

	if (isempty(GLOBALPRTIME))
		GLOBALPRTIME = 10;
	end
    
	if nargout > 0
		n_out = GLOBALPRTIME;
  end
	
	if nargin > 0
    if ischar(n_in)
      n_in = str2num(n_in);
    end
		GLOBALPRTIME = n_in;
	end
	
	if nargout == 0 && nargin == 0
		disp(GLOBALPRTIME)
	end
	
return
