function W = sod(a, fracrej, k, alpha, l)
    % Take care of empty/not-defined arguments:
    if nargin < 3 || isempty(k), k = 1; end
    if nargin < 4 || isempty(alpha), alpha = 0.8; end
    if nargin < 5 || isempty(l), l = k; end
    if nargin < 2 || isempty(fracrej), fracrej = 0.05; end
    if nargin < 1 || isempty(a) 
        % When no inputs are given, we are expected to return an empty
        % mapping:
        W = prmapping(mfilename,{fracrej, k, l, alpha});
        % And give a suitable name:
        W = setname(W,sprintf('SODDD k:%d l:%d alpha:%f', k, l, alpha));
        return
    end
    
    
    if ~ismapping(fracrej)           %training
        
        a = +target_class(a);  % make sure we have a OneClass dataset
        [m,d] = size(a);
         % calculate the euclidian distance matrix
         distmat = sqrt(sqeucldistm(a,a));
       
         % sort the distances
         [sD, index] = sort(distmat, 2);

         %index = {};
         %for i = 1:m
          %  index{i} = find(distmat(i,:) <= sD(i,k));
         %end

         count = zeros(m,m);
         for i = 1:m
             P = zeros(1, m);
             P(index(i,1:k)) = 1;
             for j = i+1:m
                count(i,j) = sum(P(index(j,1:k)));
                %count(i,j) = sum(ismember(index(i,1:k), index(j,1:k)));
                count(j,i) = count(i,j);
             end
         end
         
         [ssnn, ~] = sort(count, 2, 'desc');
         snn = {};
         for i = 1:m
            snn{i} = find(count(i,:) >= ssnn(i,l));
         end

         sod = zeros(m, 1);
         for i = 1:m
             nk = length(snn{i});
             means = mean(a(snn{i},:));
             var_actual = zeros(1, d);
             for j = 1:d
                var_actual(j) = sum((means(j) - a(snn{i},j)).^2)/nk; 
             end
             var_expect = alpha*mean(var_actual);
             var_ind = var_actual < var_expect;
             sod(i) = sqrt(sum(var_ind.*(a(i,:)-means).^2))/sum(var_ind);
         end
         sod(isnan(sod)) = 0;

        W.scores = sod;
        W.alpha = alpha;
        W.k = k;
        W.l = l;
        W.distmat = distmat;
        W.x = +a;
        W.sD = sD;
        W.index = index;
        W.out = sod;

        % obtain the threshold
        W.threshold = dd_threshold(W.scores,1-fracrej);
        W = prmapping(mfilename,'trained',W,str2mat('target','outlier'),d,2);
        W = setname(W,sprintf('SODDD k:%d l:%d alpha:%f', k, l, alpha));
    
    else                               %testing
         W = getdata(fracrej);  % unpack
         [m,d] = size(a);
         n = size(W.x, 1);
         %compute:
         bmat = sqrt(sqeucldistm(+a,W.x));    %dist between train and test
         [~, index] = sort(bmat, 2);
         count = zeros(m,n+1);

         for i = 1:m
             P = zeros(1, n+1);
             P([n+1 index(i,1:W.k-1)]) = 1;
             for j = 1:n
                if(W.sD(j, W.k) > bmat(i,j))
                    count(i,j) = sum(P([W.index(j, 1:W.k-1) n+1]));
                   % count(i,j) = sum(ismember([n+1 index(i,1:W.k-1)], [W.index(j, 1:W.k-1) n+1]));
                else
                    count(i,j) = sum(P(W.index(j, 1:W.k)));
                   % count(i,j) = sum(ismember([n+1 index(i,1:W.k-1)], W.index(j, 1:W.k)));
                end
             end
         end
         
         [ssnn, ~] = sort(count, 2, 'desc');
         snn = {};
         for i = 1:m
            snn{i} = find(count(i,:) >= ssnn(i,W.l));
         end

         sod = zeros(m, 1);
         for i = 1:m
             nk = length(snn{i});
             if nk <= n
                 means = mean(W.x(snn{i},:));
                 var_actual = zeros(1, d);
                 for j = 1:d
                    var_actual(j) = sum((means(j) - W.x(snn{i},j)).^2)/nk; 
                 end
                 var_expect = W.alpha*mean(var_actual);
                 var_ind = var_actual < var_expect;
                 sod(i) = sqrt(sum(var_ind.*(a(i,:)-means).^2))/sum(var_ind);
             else
                 sod(i) = Inf;
             end
         end
         sod(isnan(sod)) = 0;
         
        ind = sod;

        % store the results in the final dataset:
        out = [ind repmat(W.threshold,[m,1])];
        % store the distance as output:
        W = setdat(a,-out,fracrej);
        W = setfeatdom(W,{[-inf 0;-inf 0] [-inf 0; -inf 0]});
        
    end
return
