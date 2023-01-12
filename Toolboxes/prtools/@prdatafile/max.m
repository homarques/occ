%MAX Datafile overload

function [s,J] = max(a,b,dim)
	
	
	if nargin < 3, dim = 1; end
	if nargin < 2, b = []; end
	
	if isempty(b)
		
		if dim == 1
			s = -inf*ones(1,size(a,2));
			I1 = ones(1,size(a,2));
			next = 1;
			while next > 0 % indices are image (object) numbers (K)!
				[b,next,K] = readdatafile(a,next);
				[t,I2] = max(b,[],1);
				[s,J] = max([s;t],[],1);
				I = [I1;I2];
				I1 = I1.*(2-J) + K(I2).*(J-1);
			end
			J = I1;
		elseif dim == 2
			s = -inf*ones(size(a,1),1);
			J = ones(1,size(a,1));
			next = 1;
			while next > 0 % indices are pixel (feature) numbers
				[b,next,K] = readdatafile(a,next);
				[s(K),J(K)] = max(b,[],2);
			end
			J = J';
		else
			error('Illegal dimension requested')
		end
		
	else % dyadic operation
		
		[check,a,b] = check12(a,b);
	
		switch check
			case 'both'
				s = dyadic(a,'max',b);
			case 'first'
				s = a*filtm([],'max',b);
    	case 'last'
     		s = b*filtm([],'max',a);
  	end
		
	end	

return
