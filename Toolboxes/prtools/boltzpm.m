function out = boltzpm(a, scale)

  % prtrace(mfilename);

	if nargin < 2
		prwarning(3, 'no scale supplied, assuming 1');
		scale = []; 
  end
	
  try
    is_prt5 = prversion >= 5;
  catch  %#ok<CTCH>
    is_prt5 = false;  
  end
  
	% Depending on the type of call, return a mapping or sigmoid-mapped data.

	if nargin == 0 || isempty(a)
    if is_prt5
      w = prmapping(mfilename, 'fixed', scale);
    else
      w = mapping(mfilename, 'fixed', scale);
    end
		w = setname(w, 'Boltzmann Probabilities Mapping');
		out = w;
    
  else
    out = +a;
    ma = max(out, [], 2);

    if isempty(scale)
      out = exp(bsxfun(@minus, out, ma));
      %out = exp((out - repmat(ma, [1 k])));
    else
      out = exp(bsxfun(@minus, out, ma) ./ scale);
      %out = exp((out - repmat(ma, [1 k])) ./ scale);
    end  

    out = bsxfun(@rdivide, out, sum(out, 2));

    if (is_prt5 && isa(a, 'prdataset')) || isa(a, 'dataset')
      out = setdata(a, out, getfeatlab(a));
    end  
  end
  
  return