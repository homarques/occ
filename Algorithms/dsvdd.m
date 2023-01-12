%
%   Deep SVDD
% 
%   W = DSVDD(A,FRACREJ,N)
%
% 
% INPUT
%   A        Dataset
%   FRACREJ  Fraction of target objects rejected (default = 0.1)
%   N        Number of hidden units (default = 5)
%
% OUTPUT
%   W        Deep SVDD network
%
% DESCRIPTION
% Train a Deep SVDD network with N hidden units. 
%
% 

function W = dsvdd(varargin)

argin = shiftargin(varargin,'scalar');
argin = setdefaults(argin,[],0.1,5);

if mapping_task(argin,'definition')   % empty mapping
   W = define_mapping(argin,'untrained','DSVDD');

elseif mapping_task(argin,'training') 

   [a,fracrej,N] = deal(argin{:});
	a = +target_class(a);     % make sure a is an OC dataset
	[nrx,dim] = size(a);

	net = py.main.start(a(:), nrx, dim, N);
	d = transpose(double(py.main.predict(net, a(:), nrx, dim)));

	% obtain the threshold:
	W.threshold = dd_threshold(d,1-fracrej);

	%and save all useful data:
	W.net = net;
	W.scale = mean(d);
	W = prmapping(mfilename,'trained',W,str2mat('target','outlier'),dim,2);
	W = setname(W,'DSVDD (N=%d)',N);

elseif mapping_task(argin,'trained execution')  %testing

   [a,fracrej] = deal(argin{1:2});
	W = getdata(fracrej);  % unpack
	[m, d] = size(a);

	%compute distance:
	out = transpose(double(py.main.predict(W.net, +a(:), m, d)));
	out = [out repmat(W.threshold,m,1)];

	%store the distance as output:
	W = setdat(a,-out,fracrej);
	W = setfeatdom(W,{[-inf 0;-inf 0] [-inf 0;-inf 0]});
else
   error('Illegal call to DSVDD.');
	
end


