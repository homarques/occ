function nmin = nfminbnd(fun,n1,n2,itermax,varargin)

%NFMINBND Private routine for optimizing integer complexity /
%regularisation parameters


global STOPPED_BY_PRTIME
STOPPED_BYP_RTIME = false;

fmin = inf;
if n2 - n1 < itermax            % small interval, try all values
  N = [n1:n2];
  randstate = randreset(1);     % randomize to handle early stopping
  R = randperm(numel(N));
  starttime = clock;            % handle early stopping
  runtime = 0;
  for i=1:numel(N)
    if runtime > prtime, break; end
    n = N(R(i));
    ff = feval(fun,n,varargin{:});
    if ff < fmin
      nmin = n;
      fmin = ff;
    end
    runtime = etime(clock,starttime);
  end
  if runtime > prtime
    STOPPED_BY_PRTIME = true;
  end
else                            % large interval, minimise
  n0 = round((n2-n1)/2);        % start by bounds and half way
  N = [n2 n1 n0];               % points

	F = [feval(fun,n2,varargin{:}) feval(fun,n1,varargin{:}) ...
			feval(fun,n0,varargin{:})]; % function values
  ftot = sum(F);                % just to have a second stopping criterion
  ftotmin = inf;                % initially inf
  [ff,j] = min(F);              % initial minimum
  nmin = N(j);                  % at this point
  iter = 3;                     % that took already 3 function evaluations!
                                % now loop as long as we improve for at
                                % most itermax iterations
  starttime = clock;            % or until the time is gone
  runtime = 0;
  while (iter < itermax) && ((ff < fmin) || (ftot < ftotmin)) && runtime < prtime
    fmin = ff;                  % store our minimum function
    ftotmin = sum(F);           % and our set of function values
    X = [N.^2; N; [1 1 1]];     % try quadratic approximation
    a = prinv(X')*F';             % its coefficients
		if a(1) <= 0 && a(2) < 0      % wrong !! point to maximum
			nnew = nmin+1;            % go right of minimum
		elseif a(1) <= 0 && a(2) >= 0 % wrong !! 
			nnew = nmin-1;            % go left of minimum			
		else
			nnew = round(-a(2)/(2*a(1))); %  new minimum of parabola
		end

    if nnew <= n1               % if it is out of bound
      nnew = min(N) + 1;        % put it close to what we have
    elseif nnew >= n2
      nnew = max(N) - 1;
    end
    if any(N == nnew)           % we found a point we have
      j = find(N == nnew);
      F(j) = ff;                % this will force a break
		else

			fnew = feval(fun,nnew,varargin{:}); % new point, evaluate
      [fmax,j] = max(F);        % find the worst point we have
      if fnew >= fmax           % new point is worse
        iter = itermax;         % force end of search
      else                      % new point is better
        F(j) = fnew;            % take it instead
        N(j) = nnew;
      end
    end
    [ff,j] = min(F);            % minimum
    ftot = sum(F);              % total sum
    nmin = N(j);                % best point
    runtime = etime(clock,starttime);
  end
  if runtime > prtime
    STOPPED_BY_PRTIME = true;
  end
end

return
      
    
  
    