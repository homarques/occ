%PLOTC Plot classifiers
% 
%   PLOTC(W,S,LINE_WIDTH)
%   PLOTC(W,LINE_WIDTH,S)
% 
% Plots the discriminant as given by the mapping W on predefined axis,
% typically set by scatterd. Discriminants are defined by the points
% where class differences for mapping values are zero. 
%
% S is the plot string, e.g. S = 'b--'. In case S = 'col' a color plot is
% produced filling the regions of different classes with different colors.
% Default S = 'k-';
%
% LINE_WIDTH sets the width of the lines and box. Default LINE_WIDTH = 1.5
%
% In W a cell array of classifiers may be given. In S a set of plot strings
% of appropriate size may be given. Automatically a legend is added to
% the plot.
% 
% The linear gridsize is read from the global parameter GRIDSIZE, that
% can be set by the function gridsize:  for instance 'gridsize(100)'
% default gridsize is 30. As all these points have to be classified (e.g.
% 100x100) this always done in batch mode. If needed desired the default
% batch size may be changed by PRGLOBAL.
%
% Examples in PREX_CONFMAT, PREX_PLOTC
% 
% SEE ALSO (<a href="http://37steps.com/prtools">PRTools Guide</a>)
% MAPPINGS, SCATTERD, PLOTM, GRIDSIZE, SETBATCH, PRGLOBAL

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: plotc.m,v 1.6 2009/10/30 11:01:47 davidt Exp $

function handle = plotc(w,varargin)

  linew = 1.5;
  s = [];

  if nargin < 1 || isempty(w)
    handle = prmapping(mfilename,'combiner',s);
    return
  end

  % Extract the plotwidth and linewidth:
  for j = 1:nargin-1
    if ischar(varargin{j})
      s = varargin{j}; 
    else
      linew = varargin{j}; 
    end
  end

  ss = char('k-','r-','b-','m-','k--','r--','b--','m--');
  ss = char(ss,'k-.','r-.','b-.','m-.','k:','r:','b:','m:');

  % When we want to plot a list of classifiers, we set up different
  % plot strings ss and call plotc several times.
  if iscell(w)
    w = w(:);
    n = length(w);
    names = [];
    % Check if sufficient plotstrings are available
    if ~isempty(s)
      if size(s,1) == 1
        s = repmat(s,n,1);
      elseif size(s,1) ~= n
        error('Wrong number of plot strings')
      end
    else
      s = ss(1:n,:);
    end
    % Plot the individual boundaries by calling 'mfilename' (i.e. this
    % function again)
    names = [];
    hh = [];
    for i=1:n
      h = feval(mfilename,w{i},deblank(s(i,:)),linew);
      hh = [hh h(1)];
      names = char(names,getname(w{i}));
    end
    % Finally fix the legend:
    names(1,:) = [];
    legend(hh,names,'location','best');
    if nargout > 0
      handle = hh;
    end
    return
  end

  % Now the task is to plot a single boundary (multiple boundaries are
  % already covered above):
  if ~isa(w,'prmapping') || ~istrained(w)
    error('Trained classifier expected')
  end
  %w = w*setbatch;     % Avoid memory prolems with large gridsizes

  [k,c] = size(w);
  c = max(c,2);
  if nargin < 2 || isempty(s)  % default plot string
    s = 1;
  end
  %DXD: Stop when the classifier is not in 2D:
  if (k~=2)
    error('Plotc can only plot classifiers operating in 2D.');
  end

  if ~ischar(s)
    if s > 16 || s < 1
      error('Plotstring undefined')
    else
      s = deblank(ss(s,:));
    end
  end
  % Get the figure size from the current figure:
  hold on
  V=axis;
  hh = [];
  set(gca,'linewidth',linew)

  % linear discriminant
  if isaffine(w) && c == 2 && ~strcmp(s,'col')  % plot as vector
    d = +w;
    n = size(d.rot,2);
    if n == 2, n = 1; end
    for i = 1:n
      w1 = d.rot(:,i); w0 = d.offset(i);
      J = find(w1==0);
      if ~isempty(J)
        w1(J) = repmat(realmin,size(J));
      end
      x = sort([V(1),V(2),(-w1(2)*V(3)-w0)/w1(1),(-w1(2)*V(4)-w0)/w1(1)]);
      if (x(2)==x(3))  % for exactly vertical lines...
         x = x(2:3);
         y = V(3:4);
      else
         y = (-w1(1)*x-w0)/w1(2);
      end

      h = plot(x,y,s);
      set(h,'linewidth',linew)
      hh = [hh h];
    end
  else    % general case: find contour(0)
    % First define the mesh grid:
    n = gridsize;
    m = (n+1)*(n+1);
    dx = (V(2)-V(1))/n;
    dy = (V(4)-V(3))/n;
    [X,Y] = meshgrid(V(1):dx:V(2),V(3):dy:V(4));
    D = double([X(:),Y(:),zeros(m,k-2)]*w); 
    if min(D(:)) >=0, D = log(D+realmin); end  % avoid infinities

    % A two-class output can be given in one real number, avoid this
    % special case and fix it:
    if c == 2 && min(size(D)) == 1; D = [D -D]; end
    c = size(D,2); 

    if ~strcmp(s,'col')
    
      % Plot the contour lines
      if c < 3
        Z = reshape(D(:,1) - D(:,2),n+1,n+1);
        if ~isempty(contourc([V(1):dx:V(2)],[V(3):dy:V(4)],Z,[0 0]))
          [cc,h] = contour([V(1):dx:V(2)],[V(3):dy:V(4)],Z,[0 0],s);
          set(h,'linewidth',linew)
          %DXD Matlab 7 has different handle definitions:
          if str2num(version('-release'))>13,
            h = get(h,'children');
          end
          hh = [hh;h];
        end
      else
        for j=1:c-1
          L = [1:c]; L(j) = [];
          Z = reshape( D(:,j) - max(D(:,L),[],2),n+1,n+1);
          if ~isempty(contourc([V(1):dx:V(2)],[V(3):dy:V(4)],Z,[0 0]))
            [cc,h] = contour([V(1):dx:V(2)],[V(3):dy:V(4)],Z,[0 0],s);
            set(h,'linewidth',linew)
            %DXD Matlab 7 has different handle definitions:
            if str2num(version('-release'))>13,
              h = get(h,'children');
            end
            hh = [hh;h];
          end
        end
      end
    else
      % Fill the areas with some colour:
      col = 0; mapp = [hsv(c); [1 1 1]];
%       randreset; R = randperm(c); % just to see some differences better
%       mapp(1:c,:) = mapp(R,:);
      polygons = {};
      polycols = {};
      polysize = {};
      % add one column to D for undecidable : all classes equal to minimum
      % this column is slightless (0.5) than minimum and will be white.
      Dm = min(D(:));
      D = [D all(D == Dm,2)+Dm-0.5];
      for j=1:c+1
        L = [1:c+1]; L(j) = [];
        Z = reshape( D(:,j) - max(D(:,L),[],2),n+1,n+1);
        mD = min(D(:))-1;
        % DXD Matlab is now insensitive to 'inf's :-(
        % Z = [-inf*ones(1,n+3);[-inf*ones(n+1,1),Z,-inf*ones(n+1,1)];-inf*ones(1,n+3)];
        Z = [mD*ones(1,n+3);[mD*ones(n+1,1),Z,mD*ones(n+1,1)];mD*ones(1,n+3)];
        col = col + 1;
        if ~isempty(contourc([V(1)-dx:dx:V(2)+dx],[V(3)-dy:dy:V(4)+dy],Z,[0 0]))
          [cc,h] = contour([V(1)-dx:dx:V(2)+dx],[V(3)-dy:dy:V(4)+dy],Z,[0 0]);
          while ~isempty(cc)
            len = cc(2,1);
            % postpone plotting
            %h = [h;fill(cc(1,2:len+1),cc(2,2:len+1),mapp(col,:),'FaceAlpha',0.5)];
            polygons = [polygons {cc(:,2:len+1)}];
            polycols = [polycols {mapp(col,:)}];
            polysize = [polysize {polyarea(cc(1,2:len+1),cc(2,2:len+1))}];
            cc(:,1:len+1) = [];
          end
          %hh = [hh;h];
        end
      end
      % plot polygons and colors from small to large
      psize = -cell2mat(polysize);
      [dummy,rsize] = sort(psize);
      for jj=1:numel(psize)
        j = rsize(jj);
        X = polygons{j}(1,:); Y = polygons{j}(2,:);
        if isoctave
          hh = [hh;fill(X,Y,polycols{j})];
        else
          hh = [hh;fill(X,Y,polycols{j},'FaceAlpha',0.5)];
        end
      end
    end
  end
  axis(V);

  % Return the handles if they are requested:
  if nargout > 0, handle = hh; end
  hold off
  return

