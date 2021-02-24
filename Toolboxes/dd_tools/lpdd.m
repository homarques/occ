%LPDD Linear programming distance data description
%
%         W = LPDD(X,NU,S,DTYPE,DPAR)
%         W = X*LPDD([],NU,S,DTYPE,DPAR)
%         W = X*LPDD(NU,S,DTYPE,DPAR)
% 
% INPUT
%   X       Dataset
%   NU      Fraction error on target data (default = 0.1)
%   S       Scale parameter for sigmoid (default = 1)
%   DTYPE   Distance definition (default = 'd')
%   DPAR    Parameter for distance (default = 2)
%
% OUTPUT
%   W       LP distance model
%
% DESCRIPTION
% One-class classifier put into a linear programming framework. From
% the data X the distance matrix is computed (using distance DTYPE,
% see dd_proxm for the possibilities). The distances are then
% transformed using a sigmoidal transformation (with parameter S,
% see the function dissim.m) and on this the linear machine is
% trained. The parameter NU gives the possible error on the target
% class.
%
% This function is basically a wrapper around dlpdd. See dd_ex2 to
% see how it works.
%
% REFERENCE
%@inproceedings{Pekalska2002,
%	author = {Pekalska, E. and Tax, D.M.J. and Duin, R.P.W.},
%	title = {One-class {LP} classifier for dissimilarity representations},
%	booktitle = {Advances in Neural Information Processing Systems},
%	year = {2003},
%	pages = {},
%  editor =       {S.~Becker and S.~Thrun and K.~Obermayer},
%  volume =       {15},
%  publisher = {MIT Press: Cambridge, MA}
%}
% SEE ALSO
% dd_proxm, dissim, dlpdd, dd_ex2

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

%function W = lpdd(x,nu,s,dtype,par)
function W = lpdd(varargin)

argin = shiftargin(varargin,'scalar');
argin = setdefaults(argin,[],0.1,1,'d',2);

if mapping_task(argin,'definition')       % Define mapping
   W = define_mapping(argin,'untrained','LpDD');

elseif mapping_task(argin,'training')			% Train a mapping.

   [x,nu,s,dtype,par] = deal(argin{:});
	% Use all different methods:

	x = target_class(x);
	[~,dim] = size(x);
	% First define the distance mapping:
	W.wd = dd_proxm(x,dtype,par);
	% Second the distance transformation:
	W.ws = dissim([],'dsigm',s);
	% And finally do the real work in dlpdd:
	x = x*W.wd*W.ws;
	
	% work directly on the distance matrix
	[n,d] = size(x);
	% maybe we have example outliers...
	if isocset(x)
		labx = getoclab(x);
	else
		labx = ones(n,1);
	end
	x = +x; % no dataset please.
	% scale the distances to avoid numerical issues (thanks Ela!):
	sc = mean(x(:));
	x = x./sc;

	% set up the LP problem:
	if (nu > 0) && (nu <= 1),  % allow error on the training data
		C = 1./(n*nu);
		f = [1 -1 zeros(1,d) repmat(C,1,n)]';
		A = [-labx labx repmat(labx,1,d).*x  -eye(n)];
		b = zeros(n,1); 
		Aeq = [0 0 ones(1,d) zeros(1,n)];
		beq = 1;
		N = n + d + 2;
		lb = zeros(N,1);
		ub = repmat(inf,N,1);
	elseif nu == 0,       % don't allow errors on the training data
		f = [1 -1 zeros(1,d)]';
		A = [-labx labx repmat(labx,1,d).*x];
		b = zeros(n,1); 
		Aeq = [0 0 ones(1,d)];
		beq = 1;
		N = d + 2;
		lb = zeros(N,1);
		ub = repmat(inf,N,1);
	else
		error ('Illegal nu.');
	end

	%clear x;

	ctype = [repmat('S',size(Aeq,1),1);
		         repmat('U',size(A,1),1)];
	vartype = repmat('C',size(f,1),1);
	alf = glpkcc(f,[Aeq;A],[beq;b],lb,ub,ctype,vartype,1,[]);

    % store the results
	paramalf = alf(3:2+d);
	W.w.I = find(paramalf>1e-10);
	if length(W.w.I)<1
		warning('dd_tools:dlpdd:noFeatures', ...
			'No features are retained in the classifier.');
	end
	W.w.w = paramalf(W.w.I);
	W.w.sc = sc;
	W.w.threshold = alf(1)-alf(2)+1e-12;
    
    D = +x(:,W.w.I);
	W.out = D*W.w.w;

	W = prmapping(mfilename,'trained',W,str2mat('target','outlier'),dim,2);
	W = setname(W,'Distance Linear Programming Distance-data description');

	% First define the distance mapping:
	% wd = dd_proxm(x,dtype,par);
	% % % Second the distance transformation:
	% ws = dissim([],'dsigm',s);
	% % % And finally do the real work in dlpdd:
	% w = dlpdd(x*wd*ws,nu);

	% % store the results
	% W.wd = wd;
	% W.ws = ws;
	% W.w = w;
 %  	%Also set the s explicitly, useful for inspection purposes:
	% %ww = +ws;
	% %W.s = +ww{2};
	% %Because I promised that all the OCCs have a threshold, it
	% %should be given here:
	% %ww = +w;
	% W.threshold = w.data.threshold; 

	%W = prmapping(mfilename,'trained',W,str2mat('target','outlier'),size(x,2),2);
	%W = setname(W,'LpDD');
elseif mapping_task(argin,'trained execution') %testing

   [x,nu,s,dtype,par] = deal(argin{:});
	W = getdata(nu);  % unpack
	% and here we go:
	
	w = W.w;
	W = rmfield(W, 'w');
	x = x*W.wd*W.ws;
	clear W;
	m = size(x,1);

	D = +x(:,w.I)./w.sc;
	out = D*w.w;
	
	newout = [out repmat(w.threshold,m,1)];

	% Store the distance as output:
	W = setdat(x,-newout,nu);
	W = setfeatdom(W,{[-inf 0;-inf 0] [-inf 0;-inf 0]});

else
   error('Illegal call to lpdd');

end
return



