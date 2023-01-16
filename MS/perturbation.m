%Perturbation
%
%     Z = PERTURBATION(X,NRINST,PERC)
%
% INPUT
%   X        Dataset
%   NRINST   Number of perturbed dataset to be returned (default = 20)
%   PERC     Fraction of target objects rejected (default = 0.9)
%
% OUTPUT
%   Z        Perturbed datasets
%


function [data_targets] = perturbation(x, nrinst, perc)

if nargin < 3 || isempty(perc), perc = 0.9; end
if nargin < 2 || isempty(nrinst), nrinst = 20; end
if nargin < 1 || isempty(x)
	error('Incorrect call to Data Perturbation: Empty dataset');
end

%make sure we have a OneClass dataset
x = target_class(x);

%train linear SVDD
[n, d] = size(x);
w = linsvdd((oc_set(x)));
x = +x;

%increase the magnitude of the noise while the outlier acceptance is greater than 0.5
noise = 0.05;
fracrej = 1;
while fracrej > perc
	%increase the noise magnitude
	noise = noise + 0.05;
	perf = zeros(nrinst, 1);
	data_targets = cell(nrinst, 1);
	
	%generate nrinst perturbed data
	for i = 1:nrinst
		data_targets{i} = zeros(n,d);
		for j = 1:d
			data_targets{i}(:,j) = x(:,j) + normrnd(0, (noise*(max(x(:,j))-min(x(:,j)))), [n, 1]); %normrnd(0, (noise*std(x(:,j))), [n, 1]);
		end
		data_targets{i} = gendatoc([], data_targets{i});
		err = dd_error(data_targets{i}, w);
		perf(i) = err(2);
	end
	[~, k] = sort(perf);
	data_targets = data_targets(k(1:10));
	fracrej = mean(perf(k(1:10)));

end

return
