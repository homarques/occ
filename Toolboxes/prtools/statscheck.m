%STATSCHECK  Check whether the STATS toolbox is in the path

function n = statscheck
  
  n = ~isoctave;
  if (nargout == 0) && (n == false)
    error([prnewline 'Function not available under Octave'])';
  end

  n = ~isempty(ver('stats'));
  if (nargout == 0) && (n == false)
		error([prnewline 'The Matlab STATS toolbox is missing.'])
  end
		
return