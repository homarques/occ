%LOCIDD Local Correlation Integral data description
%
%   W = LOCIDD(A,FRACREJ,ALPHA,THR,MIN_N)
%   W = A*LOCIDD([],FRACREJ,ALPHA,THR,MIN_N)
%   W = A*LOCIDD(FRACREJ,ALPHA,THR,MIN_N)
%
% INPUT
%   A         Dataset
%   FRACREJ   Error on the target class (default = 0.1)
%   ALPHA     ... (default = 0.5)
%   THR       Forced threshold (default = [])
%   MIN_N     Minimum N... (default = 5)
%
% OUTPUT
%   W         LOCI
%
% DESCRIPTION
% Calculates the Local Correlation Integral data description on dataset A. 
% The algorithm is taken from:
%
% REFERENCE
% Papadimitriou, S. and Kitagawa, H. and Gibbons, P.B. and Faloutsos, C., 
% "LOCI: fast outlier detection using the local correlation integral", in 
% Proceedings of the 19th International Conference on Data Engineering, 2003
%
% SEE ALSO
% datasets, lofdd, knndd
%
% Copyright: J.H.M. Janssens, jeroen@jeroenjanssens.com
% TiCC, Tilburg University
% P.O. Box 90153, 5000 LE Tilburg, The Netherlands

%function W = locidd(a, fracrej, alpha, forced_threshold, min_n)
function W = loci(varargin)

argin = shiftargin(varargin,'scalar');
argin = setdefaults(argin,[],0.1,0.5,[],5);
  
if mapping_task(argin,'definition')       % Define mapping
   [a,fracrej,alpha,thr,min_n] = deal(argin{:});
   mapname = sprintf('LOCI a:%1.2f, min_n:%d', alpha, min_n);
   W = define_mapping(argin,'untrained',mapname);
    
elseif mapping_task(argin,'training')			% Train a mapping.
  
   [a,fracrej,alpha,forced_threshold,min_n] = deal(argin{:});
    % Extract the target-class from dataset a:
    a = +target_class(a);  
    % m = number of objects
    % d = number of dimensions
    [m,d] = size(a);

    if(m < 2)
    	warning('dd_tools:InsufficientData','Dataset contains less than 2 objects');
    end

    % Calculate the Euclidian distance matrix and sort it per object
    distmat = sqrt(sqeucldistm(a,a));
    [sD,~] = sort(distmat,2);
    
    % Each object p has a different set of (alpha) critical distances:
    critical_distances = sort([sD sD/alpha],2);
    
    % Determine for each critical distance which object should be updated:
    [all_critical_distances, ind_all_cd] = sort(critical_distances(:));
    [objects_i, ~] = ind2sub(size(critical_distances), ind_all_cd);
    duplicate_cd = [logical(diff(all_critical_distances)==0); 0];
    duplicate_ind = find(duplicate_cd == 0);

    clear duplicate_cd;
        
    % Loop through all the critical distances
    % We use a while loop so that we can skip duplicates
    %disp('Calculating mdefs for all critical distances...');
    [ns, k_sigmas] = loci_cpp(alpha, all_critical_distances, duplicate_ind, objects_i, distmat, sD, min_n);

    % In the LOCI article, the threshold k_sigma is set to 3.
    % If you which to force this, then you need to specify it as a
    % paramater. Otherwise it is computed like all other data description
    % methods.
    
    if((isempty(forced_threshold)) || (forced_threshold == -1))
        threshold = dd_threshold(k_sigmas, 1-fracrej);
    else
        threshold = forced_threshold;
    end
    % Save all useful data:
    W.x = +a;
    W.out = k_sigmas;
    W.alpha = alpha;
    % Include the matrices ns, n_hats, and mdefs so that later, a LOCI plot
    % can be created.
    %W.distmat = distmat;
    W.critical_distances = critical_distances;
    W.ns = ns;
    %W.n_hats = n_hats;
    %W.mdefs = mdefs;
    W.k_sigmas = k_sigmas;

    W.threshold = threshold;
    %W.scale = mean(k_sigmas);
    W = prmapping(mfilename,'trained',W,str2mat('target','outlier'),d,2);
    W = setname(W,sprintf('LOCI a:%1.2f, min_n:%d', alpha, min_n));
    
elseif mapping_task(argin,'trained execution')            % testing

    [a,fracrej,alpha,forced_threshold,min_n] = deal(argin{:});
    % Get the data from the training phase:
    W = getdata(fracrej);
    alpha = W.alpha;
    W = rmfield(W, 'alpha');
    threshold = W.threshold;
    W = rmfield(W, 'threshold');
    train_ns = W.ns;
    W = rmfield(W, 'ns');

    % m = number of test objects, mt = number of training objects, d = number of dimensions
    [m,~] = size(a);
    [mt,~] = size(W.x);

    k_sigmas = zeros(m,1);

    % Retrieve the critical distances of the training objects
    train_critical_distances = [W.critical_distances (Inf * ones(mt,1))];
    W = rmfield(W, 'critical_distances');
    
    % Calculate the Euclidian distance matrix.
    % This now contains the distances between the test and training
    % objects:
    distmat = sqrt(sqeucldistm(+a, W.x));  
    clear W;
    
    % Each test object has a different set of (alpha) critical distances:
    critical_distances = sort([zeros(m,1) distmat distmat/alpha],2);
    
    % Determine for each critical distance which test object should be updated:
    [all_critical_distances, ind_all_cd] = sort(critical_distances(:));
    [objects_i, ~] = ind2sub(size(critical_distances), ind_all_cd);
    duplicate_cd = [logical(diff(all_critical_distances) == 0); 0];
    duplicate_ind = find(duplicate_cd == 0);
       
    % Loop through all the critical distances
    % We use a while loop so that we can skip duplicates
    k_sigmas = loci_train(alpha, all_critical_distances, duplicate_ind, objects_i, train_critical_distances, distmat, train_ns, min_n);

    % store the results in the final dataset:
    out = [k_sigmas repmat(threshold,[m,1])];
    % Store the distance as output:
    W = setdat(a,-out,fracrej);
    W = setfeatdom(W,{[-inf 0;-inf 0] [-inf 0;-inf 0]});
else
   error('Illegal call to locidd');
end
return
