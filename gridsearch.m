function [bestargs, ret, perf] = gridsearch(train, test, clname)

%setting the parameter range
params = {};
params{1} = [0 0.05 0.1 0.15]; %fracrej
if(isequal(clname, 'abof_dd'))
	params{1} = [0 0.05 0.1 0.15];
elseif(isequal(clname, 'loci'))
	params{2} = [0.1 0.25 0.5 0.75 1];
elseif(isequal(clname, 'lof') || isequal(clname, 'knndd') || isequal(clname, 'lknn') || isequal(clname, 'sod'))
	params{2} = unique(round(linspace(2, min((size(target_class(train), 1)-1),50), 25)));
elseif(isequal(clname, 'gloshdd'))
	initgloshdd;
	params{2} = unique(round(linspace(2, min((size(target_class(train), 1)-1),50), 25)));
elseif(isequal(clname, 'libsvdd') || isequal(clname, 'lpdd') || isequal(clname, 'parzen_dd'))
	params{2} = fliplr(scale_range(target_class(train), 25));
elseif(isequal(clname, 'autoenc_dd'))
	params{2} = linspace(2, 50, 25);
elseif(isequal(clname, 'iforest_dd'))
	params{2} = fliplr([10 25 50 75 100]);
	params{3} = [0.1 0.25 0.5 0.75 1];
	params{3} = fliplr(unique(round(size(target_class(train), 1)*params{3})));
elseif(isequal(clname, 'gmm_dd'))
	params{2} = min(size(target_class(train), 1)-1,25):-1:1;
else
	warning('Method %s not found.', clname)
	exit;
end


%find first all combinations of parameters:
nrpars = length(params);
arg = params{1};
arg = arg(:); % make sure it is a column vector
for i=2:nrpars
	newarg = params{i};
	newarg = newarg(:)'; % make sure it is a row vector
	n = length(newarg);
	m = size(arg,1);
	newarg = repmat(newarg,m,1);
	arg = [repmat(arg,n,1) newarg(:)];
end
arg = num2cell(arg);
nrcomb = size(arg,1);


%now run over all combinations
bestargs = {};
nrfolds = min((size(target_class(train), 1)), 10);
ret = ones(nrcomb, 8);
ret(:,1) = 0;
ret(:,2) = -1;
ret(:,3) = -1;
perf  = zeros(nrcomb, 3);	
for i =1:nrcomb
	thisarg = arg(i,:);
    
	%cross-validation with outliers
	xval = zeros(nrfolds, 12);
	I = nrfolds;
	for j=1:nrfolds
		[x,z,I] = dd_crossval(train, I);
		try
			w = feval(clname, target_class(x), thisarg{:});
			wz = z*w;
			xval(j,1) = dd_auc(dd_roc(wz));
			xval(j,2) = dd_mcc(wz);
			[~, xval(j,3)] = dd_precatn(wz);
		catch e
			disp(e.identifier)
			xval(j,1) = 0.5;
			xval(j,2) = 0;
			xval(j,3) = 0;
		end
	end
	ret(i,1) = mean(xval(:,1));
	ret(i,2) = mean(xval(:,2));
	ret(i,3) = mean(xval(:,3));
    
	%cross-validation without outliers
	xval_err = zeros(nrfolds, 4);
	I = nrfolds;
    for j=1:nrfolds
		[x,z,I] = dd_crossval(target_class(train), I);
		try
			w = feval(clname, target_class(x), thisarg{:});
            wx = z*w;
			err = dd_error(wx);
			xval_err(1, j) = err(1);
		catch e
			disp(e.identifier)
			xval_err(1, j) = 1;
		end
    end
    
	ret(i,4) = mean(xval_err(1,:));
end


%self-adaptive data shifting
[sds_targets, sds_outliers] = sds(target_class(train));

%data perturbation
pert_targets = perturbation(target_class(train), 20, 0.5);

%uniform object generation
unif_targets = gendatout(target_class(train), 100000);

for i =1:nrcomb
	thisarg = arg(i,:);

	try
		w = feval(clname, target_class(train), thisarg{:});
		
        %self-adaptive data shifting
        wx = sds_targets*w;
		err_t = dd_error(wx);
		ret(i,5) = err_t(1);
    
        wx = sds_outliers*w;
		err_o = dd_error(wx);
		ret(i,6) = err_o(2);

		%uniform object generation
		wx = unif_targets*w;
        err_o = dd_error(wx);
		ret(i,7) = err_o(2);

		%data perturbation
		pert = zeros(10, 1);
		for j=1:10
			err = dd_error(pert_targets{j}*w);
			pert(j) = err(2);
		end
		ret(i,8) = mean(pert);
        
		wx = test*w;
		perf(i, 1) = dd_auc(dd_roc(wx));
		perf(i, 2) = dd_mcc(wx);
		[~, perf(i, 3)] = dd_precatn(wx);

	catch e
		disp(e.identifier)
		ret(i,5) = 1;
		ret(i,6) = 1;
		ret(i,7) = 1;
        ret(i,8) = 1;

		perf(i,1) = 0.5;
		perf(i,2) = 0;
		perf(i,3) = 0;
        
	end
end


%cross-validation
[~, k]=sortrows(ret(:,1:3), [-1 -2 -3]);
bestargs{1} = arg(k(1),:);

%self-adaptive data shifting
[~,k] = min(ret(:,5)+ret(:,6));
bestargs{2} = arg(k,:);

%uniform object generation
[~,k] = min(ret(:,4)+ret(:,7));
bestargs{3} = arg(k,:);

%data perturbation
[~,k] = min(ret(:,4)+ret(:,8)+cell2mat(arg(:,1)));
bestargs{4} = arg(k,:);

return
