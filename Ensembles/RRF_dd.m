%RRF_DD classifier for RRF method
% 
%       W = RRF_DD(A,FRACREJ,ranks)
%       W = A*RANDOM_DD([],FRACREJ,ranks)
%       W = A*RANDOM_DD(FRACREJ,ranks)
% 

function W = RRF_dd(varargin)

argin = shiftargin(varargin,'scalar');
argin = setdefaults(argin,[],0.1);

if mapping_task(argin,'definition')
   W = define_mapping(argin,'untrained','Random cl.');

elseif mapping_task(argin,'training')

   [a,fracrej,ranks] = deal(argin{:});
	[m,k] = size(a);

	% train it:
	% Run combining rule on given rankings
    
    W.aggR = RRF(ranks')';
    
	%and save all useful data in a structure:
	W.threshold = fracrej;  % a threshold should *always* be defined
	W = prmapping(mfilename,'trained',W,str2mat('target','outlier'),k,2);
	W = setname(W,'RRF');

elseif mapping_task(argin,'trained execution') %testing

   [a,fracrej] = deal(argin{:});
	% Unpack the mapping and dataset:
	W = getdata(fracrej);
	[m,k] = size(a); 

	newout = [W.aggR repmat(W.threshold,m,1)];

	% Fill in the data, keeping all other fields in the dataset intact:
	W = setdat(a,newout,fracrej);
	W = setfeatdom(W,{[-inf 0;-inf 0] [0 inf;0 inf]});
else
   error('Illegal call to RRF_dd');
end
return


