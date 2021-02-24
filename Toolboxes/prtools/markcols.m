%MARKCOLS Randomly change marker colors in lineplot or scatterplot
%
%	 COLS = MARKCOLS         get colors of lines and markers
%  MARKCOLS(COLS)          set colors of lines and markers
%  COLS = MARKCOLS(SEED)   randomly rotate colors of lines and markers
%
% COLS should have 3 three columns. SEED is an integer scalar.

function cols = markcols(inp)

  n = 0;
  h = get(gca,'Children')';
  line = false(1,numel(h));
  for i = h
    n = n+1;
    if strcmp(get(i,'Type'),'line')
      line(n) = true;
    end
  end
  L = find(line);

  cols = zeros(numel(L),3);
  for i = 1:numel(L)
    cols(L(i),:) = get(h(L(i)),'Color');
  end

  if nargin > 0
    if numel(inp) == 1
      seed = randreset(inp);
      R = randperm(numel(L));
      cols = cols(R,:);
      for i=1:numel(L)
        set(h(L(i)),'Color',cols(i,:));
      end
      randreset(seed)
    elseif size(inp,2) == 3
      cols = inp;
      for i=1:min(numel(L),size(cols,1))
        set(h(L(i)),'Color',cols(i,:));
      end
    else
      error('Color matrix should have 3 columns')
    end
    
  end
  



