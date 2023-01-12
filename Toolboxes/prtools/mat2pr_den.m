%MAT2PR_DEN Convert Matlab dendrogram to PRTools format
%
%   DEN_PR = PR2MAT_DEN(DEN_MAT)

function den = mat2pr_den(z)

zorg = z;

[m,k] = size(z);
if k~=3
  error('Input is not a Matlab dendrogram')
end
m = m+1;
W = 1:m+1;               % starting points of clusters in linear object set.
V = 1:m+2;               % positions of objects in final linear object set.
R = 1:m;                 % rows/columns that still participate
F = inf * ones(1,m+1);   % distance of next cluster to previous cluster 
                           % to be stored at first point of second cluster
change = true;
while change
  change = false;
  for i=1:m-1
    if i == 19
      xxx = 13;
    end
    if z(i,1) > m
      z(i,1) = z(z(i,1)-m,1);
      z(i,1:2) = sort(z(i,1:2),2);
      change = true;
    end
    if z(i,2) > m
      z(i,2) = z(z(i,2)-m,1);
      change = true;
      z(i,1:2) = sort(z(i,1:2),2);
    end
  end
end

L = ones(1,m);
C = 1:m;
for n=1:m-1
  [ii,jj,dj] = deal(z(n,1),z(n,2),z(n,3));
  i = sum(L(1:ii));
  j = sum(L(1:jj));
  C(jj+1:end) = C(jj:end-1);
  L(jj) = 0;
  F(V(j)) = dj;
  if n==19
    xxx = 13;
  end
  % move second cluster in linear ordering right after first cluster
  IV = [1:V(i+1)-1,V(j):V(j+1)-1,V(i+1):V(j)-1,V(j+1):m+1];
  W = W(IV); F = F(IV);   
  % keep track of object positions and cluster distances
  V = [V(1:i),V(i+1:j) + V(j+1) - V(j),V(j+2:m-n+3)];
end
den = [W(1:m);F(1:m)];