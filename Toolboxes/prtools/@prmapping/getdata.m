%GETDATA Get data fields in mapping
%
%    DATA = GETDATA(W)
%
% Get content of data field of W
%
%    DATA = GETDATA(W,N)
%
% Get content of N-th cell in W.DATA.
%
%    DATA = GETDATA(W,FIELD)
%
% Get content of desired field if W.DATA is structure

% $Id: getdata.m,v 1.7 2009/09/30 13:43:17 duin Exp $

function varargout = getdata(w,varargin)
		
  varargout = cell(1,nargout);
  if nargin > 1
    if iscell(w.data)
      for j=1:numel(varargin)
        if is_scalar(varargin{j})
          varargout{j} = w.data{varargin{j}};
        else
          error('Illegal data item requested in mapping')
        end
      end
    elseif isstruct(w.data)
      for j=1:numel(varargin)
        if isfield(w.data,varargin{j})
          varargout{j} = getfield(w.data,varargin{j});
        else
          error('Illegal data field requested in mapping')
        end
      end
    else
      for j=1:numel(varargin)
        varargout{j} = w.data(varargin{j});
      end
    end
  elseif iscell(w.data) && nargout > 1
    for j=1:min(nargout,numel(w.data))
      varargout{j} = w.data{j};
    end
  else
    varargout{1} = w.data;
  end
		
return
