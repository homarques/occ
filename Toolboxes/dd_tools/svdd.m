%SVDD Support Vector Data Description
% 
%       W = SVDD(A,FRACREJ,SIGMA)
%       W = A*SVDD([],FRACREJ,SIGMA)
%       W = A*SVDD(FRACREJ,SIGMA)
%
% INPUT
%   A         One-class dataset
%   FRACREJ   Error on the target class (default = 0.1)
%   SIGMA     Width parameter in the RBF kernel (default = 5)
%
% OUTPUT
%   W         Support vector data description
% 
% DESCRIPTION
% Optimizes a support vector data description for the dataset A by 
% quadratic programming. The data description uses the Gaussian kernel
% by default. FRACREJ gives the fraction of the target set which will
% be rejected, when supplied FRACERR gives (an upper bound) for the
% fraction of data which is completely outside the description.
%
% Note: this version of the SVDD is not compatible with older dd_tools
% versions. This is to make the use of consistent_occ.m possible.
%
% Further note: this classifier is one of the few which can actually
% deal with example outlier objects!
% 
% REFERENCE
%@article{Tax1999c,
%	author = {Tax, D.M.J. and Duin, R.P.W},
%	title = {Support vector domain description},
%	journal = {Pattern Recognition Letters},
%	year = {1999},volume = {20},
%	number = {11-13},pages = {1191-1199}
%}
%
% SEE ALSO
% incsvdd, svdd_optrbf, dd_roc.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
  
%function W = svdd(a,fracrej,sigma)
function W = svdd(varargin)

argin = shiftargin(varargin,'scalar');
argin = setdefaults(argin,[],0.1,5);

if mapping_task(argin,'definition')
   W = define_mapping(argin,'untrained','SVDD');

elseif mapping_task(argin,'training')
   [a,fracrej,sigma] = deal(argin{:});
	if isempty(sigma)
		error('This versions needs a sigma.');
	end
	% introduce outlier label for outlier class if it is available.
	if isocset(a)
		signlab = getoclab(a);
		if all(signlab<0), error('SVDD needs target objects!'); end
	else
		%error('SVDD needs a one-class dataset.');
      % Noo, be nice, everything is target:
      signlab = ones(size(a,1),1);
		%a = target_class(+a);
	end
	% check the rejection rates
	if (length(fracrej)>2) % if no bound on the outlier error is given, we
		if length(fracrej)~=length(signlab)
			error('The length of C is not fitting.');
		end
		C = fracrej;
	else
		if (length(fracrej)<2) % if no bound on the outlier error is given, we
									 % do not care
			fracrej(2) = 1;
		end
		if (fracrej(1)>1)
			warning('dd_tools:AllReject',...
				'Fracrej > 1? I cannot reject more than all my target data!');
		end
		% Setup the appropriate C's
        if (fracrej(1)<0) %DXD: tricky trick....
            C(1) = -fracrej(1);
            C(2) = -fracrej(2);
        else
            nrtar = length(find(signlab==1));
            nrout = length(find(signlab==-1));
            % we could get divide by zero, but that is ok.
            %warning off MATLAB:divideByZero;
                C(1) = 1/(nrtar*fracrej(1));
                C(2) = 1/(nrout*fracrej(2));
            %warning on MATLAB:divideByZero;
        end
	end

	% Find the alpha's
	% Standard optimization procedure:
	[alf,R2,Dx,J] = svdd_optrbf(sigma,+a,signlab,C);
	SVx = +a(J,:);
	alf = alf(J);
	% Compute the offset (not important, but now gives the possibility to
	% interpret the output as the distance to the center of the sphere)
	offs = 1 + sum(sum((alf*alf').*exp(-sqeucldistm(SVx,SVx)/(sigma*sigma)),2));

	% store the results
	W.s = sigma;
	W.a = alf;
	W.threshold = offs+R2;
	W.sv = SVx;
	W.offs = offs;
	W = prmapping(mfilename,'trained',W,char('target','outlier'),size(a,2),2);
	W = setname(W,'SVDD');
elseif mapping_task(argin,'trained execution') %testing

   [a,fracrej] = deal(argin{1:2});
	W = getdata(fracrej);
	m = size(a,1);

	% check if alpha's are OK
	if isempty(W.a)
		warning('dd_tools:OptimFailed','The SVDD is empty or not well defined');
		out = zeros(m,1);
    else
    	% and here we go:
        K = exp(-sqeucldistm(+a,W.sv)/(W.s*W.s));
        out = W.offs - 2*sum( repmat(W.a',m,1).* K, 2);
    end
	newout = [out repmat(W.threshold,m,1)];

	% Store the distance as output:
	W = setdat(a,-newout,fracrej);
	W = setfeatdom(W,{[-inf 0; -inf 0] [-inf 0; -inf 0]});
else
   error('Illegal call to SVDD.');
end
return


