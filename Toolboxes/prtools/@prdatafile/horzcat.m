%HORZCAT Datafile overload: horizontal concatenation

function a = horzcat(varargin)

	% STARTS contains the position of the second datafile to concatenate.

	a = varargin{1}; start = 2;

	% A call like A = [B]:    
	if (nargin == 1), return; end       
    
	% A call like A = [ [] B ... ]:
	if (isempty(a))
		a = varargin{2}; start = 3;
	end

  if (~isdatafile(a))
  	error('First argument should be a datafile');
  end

  [m,k] = size(a);
  %a = setfeatsize(a,k);
	
	% Extend datafile A by the other datafiles given.

  for i = start:length(varargin)  

  	b = varargin{i}; 
		isdatafile(b);
		% datafiles should have the same basefiles
		if (~isequal(a.files,b.files)) || (~isequal(getident(a),getident(b)))
			error(['Datafiles to be concatenated should be based on the same files.' prnewline ...
          'Use SAVEDATAFILE to concatenate datafiles with different sources.'])
		end
		
  	[mb,kb] = size(b);
  	%b = setfeatsize(b,kb);
	
		% Check whether sizes correspond.
  	if (mb ~= m)
  		error('Datafiles should have equal numbers of objects.');
  	end

		[na,sa] = size(a.preproc);
		[nb,sb] = size(b.preproc);
		if isempty(a.postproc) && na == 1
			a.preproc(sa+1).preproc = 'concatenate';
			%b.preproc.pars
			%a.preproc(sa+1).pars = b.preproc.pars;
			a.preproc(sa+1).pars = b.preproc;       % OK ???
		else		
			a.preproc(na+1:na+nb,1:sb) = b.preproc;
			%a.postproc = [a.postproc; b.postproc]; % seems to be no horzcat
			a.postproc = [a.postproc b.postproc];
  	end
% 		[ka1,ka2,ka3] = getfeatsize(a);
% 		[kb1,kb2,kb3] = getfeatsize(b);
% 		if ka1 == kb1 && ka2 == kb2
% 			a.prdataset = setfeatsize(a.prdataset,[ka1 ka2 ka3+kb3]);
% 		else
% 			a.prdataset = setfeatsize(a.prdataset,k+kb);
% 		end
		
	end
	
return
