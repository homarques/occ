%PR2MAT_DEN Convert PRTools dendrogram to Matlab format
%
%   DEN_MAT = PR2MAT_DEN(DEN_PR)

function den_mat = pr2mat_den(den)

[n,m] = size(den);
den_mat = zeros(m-1,3);

if n~=2
  error('Input is not a PRTools dendrogram')
end

clust = zeros(2*m,2);   % cluster between two dendrogram positions
clust(1:m,:) = repmat([1:m]',1,2);
P = den(1,:);           % object positions in dendrogram
[~,R] = sort(den(2,:)); % R is the processing order
for j=1:m-1             % in each step we merge clusters R(j) and R(j)-1
  for r = clust(R(j)-1,1):clust(R(j),2)
    clust(r,:) = [clust(R(j)-1,1) clust(R(j),2)];
  end
  den_mat(j,:) = [P(clust(R(j)-1,1)) P(clust(R(j),2)) den(2,R(j))];
  P(clust(R(j)-1,1):clust(R(j),2)) = m+j;
end
den_mat(:,1:2) = sort(den_mat(:,1:2),2);