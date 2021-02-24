#include <math.h>
#include <matrix.h>
#include <mex.h>
#include <stdlib.h>

// A comparator function used by qsort 
int compare(const void * a, const void * b) 
{ 
    return ( *(int*)a - *(int*)b ); 
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    //declare variables
    double alpha, alpha_r, r, *all_critical_distances, *duplicate_ind, *objects_i, *distmat, *sD, *ns;
    int cdi, duplicate_ind_i, to_cdi, min_n;
    mwSize m, all_critical_distances_size;
        
    alpha = mxGetPr(mxDuplicateArray(prhs[0]))[0];
    all_critical_distances = mxGetPr(mxDuplicateArray(prhs[1]));
    duplicate_ind =  mxGetPr(mxDuplicateArray(prhs[2]));
    objects_i = mxGetPr(mxDuplicateArray(prhs[3]));
    all_critical_distances_size = mxGetM(prhs[1]);
    
    distmat = mxGetPr(mxDuplicateArray(prhs[4]));
    sD = mxGetPr(mxDuplicateArray(prhs[5]));
    min_n = (int) mxGetPr(mxDuplicateArray(prhs[6]))[0];
    
    m = mxGetM(prhs[4]);
    int critical_distance_index[m];
    int current_alpha_neighborhood_size[m];
    //int current_neighborhood[m*m];
    int* current_neighborhood = (int*) malloc(m*m*sizeof(int));
    plhs[0] = mxCreateDoubleMatrix(m, 2*m, mxREAL);
    ns = mxGetPr(plhs[0]);
    plhs[1] = mxCreateDoubleMatrix(m, 1, mxREAL);
    double* k_sigmas = mxGetPr(plhs[1]);

    for(int i = 0; i < m; i++){
        critical_distance_index[i] = -1;
        current_alpha_neighborhood_size[i] = 0;
        k_sigmas[i] = 0;
        for(int j = 0; j < m; j++)
            current_neighborhood[m*i+j] = 0;
    }
    
    cdi = 0;
    duplicate_ind_i = 0;
    //objects = (int*) malloc((to_cdi-cdi) * sizeof(int));
    while(cdi < all_critical_distances_size){
        //Retrieve the actual range and alpha range:
        r = all_critical_distances[cdi];
        //mexPrintf("%f\n", r);
        alpha_r = alpha * r;
        //mexPrintf("%f\n", alpha_r);
        
        //Are there duplicates of this critical distance?
        to_cdi = (int) (duplicate_ind[duplicate_ind_i] - 1);
        //mexPrintf("%d\n", to_cdi);
        duplicate_ind_i++;
        //mexPrintf("%d\n", duplicate_ind_i);
        
        //Which objects have this as a critical distance? (usually two)
        int objects[(to_cdi-cdi+1)];
        for(int i = 0; i <= (to_cdi-cdi); i++){
            objects[i] = (int)objects_i[cdi+i];
           // mexPrintf("%d\n", objects[i]);
        }
        
        /* When an object has this critical distance more than once (when
           there are two other objects with the same distance to it), we
           increase their critical distance index with more than one: */
        qsort(objects, (to_cdi-cdi+1), sizeof(int), compare);
        int difference[(to_cdi-cdi+1)];
        int nz = 1;
        for(int i = 0; i < (to_cdi-cdi); i++){
           difference[i] = objects[i+1] - objects[i];
           if(difference[i] > 0)
               nz++;
        }
        difference[to_cdi-cdi] = 1;
        
        int count_t[nz+1];
        int j = 1;
        count_t[0] = 1;
        int objects_to_update[nz];
        for(int i = 0; i <= (to_cdi-cdi); i++){
            if(difference[i] > 0){
                objects_to_update[j-1] = objects[i]-1;
                count_t[j] = i + 2;
                j++;
            }
        }
        
        int count[nz];
        for(int i = 0; i < nz; i++){
            count[i] = count_t[i+1] - count_t[i];
            critical_distance_index[objects_to_update[i]] = critical_distance_index[objects_to_update[i]] + count[i];
        }
        
        // objects_to_update now contains only unique objects
        
        // We need to update their neighborhoods first because they might
        // influence each other with respect to MDEF and k_sigma etc (see below).
        // Also note that LOCI distinguishes between a sampling (alpha)
        // neighborhood and a counting neighborhood. That's why we have both
        // r and alpha_r.
        int n_of_r_neighbors_sizes[nz];
        for(int i = 0; i < nz; i++){
            n_of_r_neighbors_sizes[i] = 0;
            current_alpha_neighborhood_size[objects_to_update[i]] = 0;
            for(int j = 0; j < m; j++){
                // Update the alpha neighborhood size:
                if( sD[objects_to_update[i]+j*m] <= alpha_r){
                     current_alpha_neighborhood_size[objects_to_update[i]]++;
                }
                // Update the couting neighborhood matrix:
                if(distmat[objects_to_update[i]+j*m] <= r){
                    current_neighborhood[objects_to_update[i]+j*m] = 1;
                    n_of_r_neighbors_sizes[i]++;
                }
            }
        }
        
        int i = -1;
        double n;
        for(int j = 0; j < nz; j++){
            // n = sampling neighborhood count:
            n = current_alpha_neighborhood_size[objects_to_update[j]];
            // n_hat = mean of sampling neighborhood count of the neighbors
            // within the counting neighborhood:
            int n_of_r_neighbors[n_of_r_neighbors_sizes[j]];
            int l = 0;
            for(int k = 0; k < m; k++){
                if(current_neighborhood[objects_to_update[j]+k*m] > 0){
                    n_of_r_neighbors[l] = current_alpha_neighborhood_size[k];
                    l++;
                }
            }
            double n_hat = 0, mdef;
            for(int k = 0; k < n_of_r_neighbors_sizes[j]; k++)
                n_hat +=  n_of_r_neighbors[k];
            n_hat /= l;

            // MDEF = multi-granularity deviation factor:
            mdef = 1 - (n / n_hat);
            
            // Standard deviation of alpha-neighborhood size of r-neighbors:
            // (with 1e-10 we suppress the divide by zero warning)
            int sample_size = 0;
            for(int k = 0; k < m; k++)
                sample_size += current_neighborhood[k+m*objects_to_update[j]];

            double std_n_of_r_neighbors = 0;
            for(int k = 0; k < n_of_r_neighbors_sizes[j]; k++)
               std_n_of_r_neighbors += pow(n_of_r_neighbors[k] - n_hat, 2);
            std_n_of_r_neighbors = sqrt(std_n_of_r_neighbors/n_of_r_neighbors_sizes[j]) + 1e-10;
            double normalized_deviation = std_n_of_r_neighbors / n_hat;
            double k_sigma = mdef / normalized_deviation;
            //mexPrintf("%f\n", k_sigma);
            // Get the critical distance indices of this object for which
            // we are updating. Again, equal to the number of duplicate
            // critical distances r:
            i = i + 1;
            int indices_to_update[count[i]];
            for(int k = 0; k < count[i]; k++){
                ns[(objects_to_update[j] + (critical_distance_index[objects_to_update[j]] - count[i] + k + 1) *m)] = n; 
                //indices_to_update[k] = critical_distance_index[objects_to_update[j]] - count[i] + k +1;
               // mexPrintf("%d\n", indices_to_update[k]);
            }
            
             // For stability (see article, min_n is 20 by default)
            if(sample_size >= min_n){
                if(k_sigmas[objects_to_update[j]] > k_sigma) 
                    k_sigmas[objects_to_update[j]] = k_sigmas[objects_to_update[j]];
                else
                    k_sigmas[objects_to_update[j]] = k_sigma;
            }
            
        }

        cdi = to_cdi + 1;
    
    }
    
    free(current_neighborhood);

    return;
}