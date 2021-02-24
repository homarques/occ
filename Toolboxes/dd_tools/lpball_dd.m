%LPBALL_DD L_p ball description
%
%    W = LPBALL_DD(X,FRACREJ,BTYPE,P)
%    W = X*LPBALL_DD([],FRACREJ,BTYPE,P)
%    W = X*LPBALL_DD(FRACREJ,BTYPE,P)
%
% INPUT
%   X         Dataset
%   FRACREJ   Error on the target class (default = 0.1)
%   BTYPE     The type of optimization (see DESCRIPTION) (default = 'p')
%   P         degree P (default = 2)
%
% OUTPUT
%   W         L_p ball description
%
% DESCRIPTION
% Optimize a L_p ball around dataset X, rejecting FRACREJ fraction of
% the data. The type of ball can be:
%   BTYPE :
%    'w'       optimize the weights per feature
%    'center'  optimize the center
%    'p'       optimize the center and p
%
% SEE ALSO
% ball_dd, svdd, dd_proxm, lpball_distmean

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

%function W = lpball_dd(a,fracrej,btype,p)
function W = lpball_dd(varargin)

argin = shiftargin(varargin,'scalar');
argin = setdefaults(argin,[],0.1,'p',2);
  
if mapping_task(argin,'definition')       % Define mapping
   W = define_mapping(argin,'untrained','Lp ball');

elseif mapping_task(argin,'training')			% Train a mapping.

   [a,fracrej,btype,p] = deal(argin{:});
	a = target_class(a);     % only use the target class
	[m,k] = size(a);

	% default values:
	W.p = p;
	W.w = ones(1,k);
	% train it:
	switch btype
	case 'w'
		if size(a,1)>1  % I have more than 1 datapoint (gives problems otherwise)

			% check if all the features do something:
			x = +a;
			newk = k;
			J = (var(x)<=1e-9);
			I = find(J);
			if ~isempty(I)
				message(5,'Removed the features with zero variance!');
				x(:,I) = [];
				newk = k - length(I);
			end
			% now we need the 'inverse' of J:
			I = find(~J);

			% something like a L_p distance
			meanx = mean(x);
			x = abs(x - repmat(meanx,m,1)).^p;

			% setup the LP:
			f = [zeros(1,newk) 1]';
			A = [    x    -ones(m,1)];
			b = zeros(m,1);
			Aeq = [ones(1,newk) 0];
			beq = 1;
			lb = zeros(newk+1,1);
			ub = repmat(inf,newk+1,1);

			% optimize it:
			if (exist('glpkmex')>0)
				message(5,'Using glpk optimizer.\n');
				ctype = [repmat('S',size(Aeq,1),1);
							repmat('U',size(A,1),1)];
				vartype = repmat('C',size(f,1),1);
				w = glpkmex(1,f,[Aeq;A],[beq;b],ctype,lb,ub,vartype);
			else
				w = linprog(f,A,b,Aeq,beq,lb,ub);
			end
			% use the k features and make a row vector
			W.thr = w(newk+1);
			w = w(1:newk);
			W.w = zeros(1,k);
			W.w(I) = w(:)';
			W.mn = zeros(1,k);
			W.mn(I) = meanx;
		else % only one object in the training set
			W.mn = +a(1,:);
			W.thr = 0;
		end
	case {'center' 'c'}  % optimization of center, given p and w
		opts = optimset('Display','off','GradObj','on','Hessian','on','Diagnostics','off');
		W.mn = fminunc('lpball_dist',mean(+a,1),opts,+a,p,fracrej);
	case 'p'              % optimization of both the center and p
		par = [log(2) mean(+a,1)];  % initialization of p, center and slacks
		opts = optimset;
		opts.MaxFunEvals = 1e4;
		opts.TolFun = 0.1;  %???
		% go:
		alf = fminsearch('lpball_vol',par,opts,+a,fracrej);
		% store the results:
		W.p = exp(alf(1));
		W.mn = alf(2:k+1);
	otherwise
		error('This ball-type is not known');
	end

	% get the threshold:
	diff = lpdist(+a,W.mn,W.p,W.w);
	W.threshold = dd_threshold(diff,1-fracrej);

	%and save all useful data in a structure:
	W = prmapping(mfilename,'trained',W,str2mat('target','outlier'),k,2);
	W = setname(W,'LpBall one-class classifier');

elseif mapping_task(argin,'trained execution') %testing

   [a,fracrej] = deal(argin{1:2});
	% Unpack the mapping and dataset:
	W = getdata(fracrej);
	[m,k] = size(a); 

	% Find the distance:
	out = lpdist(+a,W.mn,W.p,W.w);

	newout = [out repmat(W.threshold,m,1)];

	% Fill in the data, keeping all other fields in the dataset intact:
	W = setdat(a,-newout,fracrej);
	W = setfeatdom(W,{[-inf 0;-inf 0] [-inf 0;-inf 0]});
else
   error('Illegal call to lpball_dd.');
end
return


