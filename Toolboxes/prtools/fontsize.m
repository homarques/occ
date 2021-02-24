%FONTSIZE Set large graphic font
%
%       fontsize(size,weight)
%
% Set font size for current figure

function fontsize(size,weight)

  if nargin < 2, weight = 'normal'; end
  V = axis;
  H = get(gcf,'Children');
	c1 = [];
	for h = H'
	if strcmp(get(h,'type'),'axes')
  	set(get(h,'XLabel'), 'FontSize', size, 'FontWeight', weight);
  	set(get(h,'YLabel'), 'FontSize', size, 'FontWeight', weight);
  	set(get(h,'ZLabel'), 'FontSize', size, 'FontWeight', weight);
  	set(get(h,'Title'),  'FontSize', size, 'FontWeight', weight);
  	set(get(h,'Title'),  'FontWeight', weight);
  	set(h, 'FontSize', size, 'FontWeight', weight);
  	c1 = [c1; get(gca, 'Children')];
	end
	end
 	axis(V);
  for h1 = c1'
    v1 = get (h1);
    if (isfield (v1, 'FontSize'))
      set (h1, 'FontSize', size, 'FontWeight', weight);
    end;
    c2 = get (h1, 'Children');
    for h2 = c2'
      v2 = get (h2);
      if (isfield (v2, 'FontSize'))
        set (h2, 'FontSize', size, 'FontWeight', weight);
      end;
    end;
  end;

return

