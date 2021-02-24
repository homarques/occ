%SCATTERN Simple 2D scatterplot of dataset without axis annotation
%
%   SCATTERN(A,LEGEND,CMAP)
%   A*SCATTERN([],LEGEND,CMAP)
%   A*SCATTERN(LEGEND,CMAP)
%
% INPUT
%   A       Dataset
%   LEGEND  Logical, true/false for including legend, default false
%   CMAP    Desired colormap, default standard
%           'labels' plots the object labels instead of dots
%           'idents' plots the object idents instead of dots
%
% DESCRIPTION
% A simple, unannotated 2D scatterplot is created, without any axes.
%
% SEE ALSO (<a href="http://37steps.com/prtools">PRTools Guide</a>)
% DATASETS, SCATTERD, GETLABELS, GETIDENT

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com

function varargout = scattern(varargin)

varargout = {};
argin = shiftargin(varargin,'logical');
argin = shiftargin(argin,'scalar');
argin = setdefaults(argin,[],false,[],'k');
if mapping_task(argin,'definition')
  % standard return, name = filename
  varargout = {define_mapping(argin,'fixed')};
elseif mapping_task(argin,'fixed execution')
  % a call like w = template(a,parsin)
  [a,plotlegend,cmap,col] = deal(argin{:});
  if isoctave
    if size(a,2) == 2
      cmap = char('b.','r.');
    else
      cmap = [];
    end
    scatterd(a,2,cmap);
    axis off;
    legend off;
    marksize(12);
    title('')
    set(gcf,'color',[0.8 0.8 0.8]);
    if plotlegend
      legend(getlablist(a))
    end
    return
  end
  if isdataset(a)
    nlab = getnlab(a);
    if getsize(a,3) == 2 && isempty(cmap)
      cmap = char('b','r');
    end
  else
    nlab = []; 
  end
  if ~ischar(cmap)
    h = gscatter(+a(:,1),+a(:,2),nlab,cmap,'.',9,'off');
  elseif strcmpi(cmap,'labels') || strcmpi(cmap,'label')
    h1 = gscatter(+a(:,1),+a(:,2),nlab,[1 1 1],'.',1,'off');
    lablist = getlablist(a,'string');
    h2 = text(+a(:,1),+a(:,2),deblank(lablist(getnlab(a),:)),'HorizontalAlignment','left','color',col);
    h = [h1;h2];
  elseif strcmpi(cmap,'idents') || strcmpi(cmap,'ident')
    h1 = gscatter(+a(:,1),+a(:,2),nlab,[1 1 1],'.',1,'off');
    iden = getident(a);
    if iscell(iden)
      iden = char(iden);
    elseif ~ischar(iden)
      iden = num2str(iden);
    end
    h2 = text(+a(:,1),+a(:,2),iden,'HorizontalAlignment','center');
    h = [h1;h2];
  else
    h = gscatter(+a(:,1),+a(:,2),nlab,cmap,'.',9,'off');
    %error('Illegal input')
  end
  fontsize(16)
  %axis equal
  axis tight
  axis off
  if plotlegend
    legend(h,getlablist(a,'string'))
  end
  set(gcf,'color',[0.8 0.8 0.8])
  if nargout > 0
    varargout = {h};
  end
end
  