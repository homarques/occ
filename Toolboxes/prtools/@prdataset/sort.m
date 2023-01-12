%SORT prdataset overload

% $Id: sort.m,v 1.3 2007/03/22 07:45:54 duin Exp $

function [s,I] = sort(a,varargin)
				
  nodatafile(a);
    
  [dim,mode] = setdefaults(varargin,1,'ascend');
  [d,I] = sort(a.data,dim,mode);
  s = setdata(a,d);

return

