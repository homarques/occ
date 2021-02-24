function main(filename, clname, experiment, class)

%Importing libraries
%http://www.prlab.tudelft.nl/david-tax/
addpath('Toolboxes/prtools'); 
addpath('Toolboxes/dd_tools');

addpath('Algorithms')
addpath('Algorithms/libsvm')
addpath('Algorithms/libsvm/matlab')
addpath('Algorithms/iforest')
addpath('Algorithms/GLOSH')
addpath('Algorithms/GLPKmex')

addpath('MS')
addpath('Measures')
addpath('Ensembles')

if(~isempty(strfind(filename, 'gaussian')))
	fullname = strcat('Datasets/Synthetic/synth-batch1/', filename, '.mat');
else
	fullname = strcat('Datasets/Real/', filename, '.mat');
end

load(fullname);
inlierClasses = getuser(data,'inliers'); % quick hack to store which classes to use as target from dataset
currentClass  = inlierClasses(str2num(class)); % using the ith class as target class

if(experiment ~= '2')
		oc_data = oc_set(data, currentClass);
	else
		oc_data = oc_set(data, setdiff(inlierClasses, currentClass));
end

[train, test] = gendat(oc_data, 0.8);
[bestargs, ret, perf] = gridsearch(train, test, clname);

auc = {};
mcc = {};
prec = {};
rankings = {};
for i = 1:size(bestargs, 2)
	if(~isempty(bestargs{i}))
		w = feval(clname, target_class(train), bestargs{i}{:});
		wx = test * w;
		rankings{i} = +wx(:,1);
		auc{i} = dd_auc(dd_roc(wx));
		mcc{i} = dd_mcc(wx);
		[ ~, prec{i}] = dd_precatn(wx);
	end
end