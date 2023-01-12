%FIND Datafile overload

function [i,j,v] = find(a)
	
	  
  if nargout == 1
	  i = a*filtm([],'find');
  else
    error('FIND operation with more than one output not implemented for datafiles')
  end
		
return
