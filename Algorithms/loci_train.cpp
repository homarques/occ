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

    int cdi, duplicate_ind_i, to_cdi, min_n;
    double *all_critical_distances, alpha, r, *duplicate_ind, alpha_r, *objects_i, *train_critical_distances, *distmat, *train_ns;
    mwSize num_all_critical_distances, m, mt;

    alpha = mxGetPr(mxDuplicateArray(prhs[0]))[0];
    all_critical_distances = mxGetPr(mxDuplicateArray(prhs[1]));
    num_all_critical_distances = mxGetM(prhs[1]);
    duplicate_ind =  mxGetPr(mxDuplicateArray(prhs[2]));
    objects_i = mxGetPr(mxDuplicateArray(prhs[3]));
    train_critical_distances = mxGetPr(mxDuplicateArray(prhs[4]));
    distmat = mxGetPr(mxDuplicateArray(prhs[5]));
    train_ns = mxGetPr(mxDuplicateArray(prhs[6]));
    min_n = (int) mxGetPr(mxDuplicateArray(prhs[7]))[0];

    m = mxGetM(prhs[5]);
    mt = mxGetN(prhs[5]);

    double train_next_critical_distance[mt];
    int train_current_critical_distance_index[mt];
    int train_current_alpha_neighborhood_size[mt];
    
    plhs[0] = mxCreateDoubleMatrix(m, 1, mxREAL);
    double* k_sigmas = mxGetPr(plhs[0]);

    int update_indices[mt];
    int sum_update_indices;
    for(int i = 0; i < mt; i++){
        train_next_critical_distance[i] = train_critical_distances[mt+i];
        train_current_critical_distance_index[i] = 1;
        train_current_alpha_neighborhood_size[i] = 1;
    }

    cdi = 0;
    duplicate_ind_i = 0;
    
    // Loop through all the critical distances
    // We use a while loop so that we can skip duplicates
    while(cdi < num_all_critical_distances){
      //  mexPrintf("%d\n", cdi);
        //Retrieve the actual range and alpha range:
        r = all_critical_distances[cdi];
        alpha_r = alpha * r;

        sum_update_indices = 0;
        for(int i = 0; i < mt; i++){
            if(r > train_next_critical_distance[i]){
                update_indices[i] = 1;
            }else{
                update_indices[i] = 0;
            }
            sum_update_indices = sum_update_indices + update_indices[i];
        }

        // Update the neighborhood sizes of the objects
        while(sum_update_indices > 0){
            sum_update_indices = 0;
            for(int i = 0; i < mt; i++){
                train_current_critical_distance_index[i] = train_current_critical_distance_index[i] + update_indices[i];
                train_current_alpha_neighborhood_size[i] = train_ns[(mt * (train_current_critical_distance_index[i]-1) + i)];
                train_next_critical_distance[i] = train_critical_distances[(mt * (train_current_critical_distance_index[i]) + i)];

                if(r > train_next_critical_distance[i]){
                    update_indices[i] = 1;
                }else{
                    update_indices[i] = 0;
                }
                sum_update_indices = sum_update_indices + update_indices[i];
            }
        }

        to_cdi = (int) (duplicate_ind[duplicate_ind_i] - 1);
        duplicate_ind_i++;
        int objects[(to_cdi-cdi+1)];
        for(int i = 0; i <= (to_cdi-cdi); i++){
            objects[i] = (int)objects_i[cdi+i];
        }

        int nz = 1;
        int difference[(to_cdi-cdi+1)];

        if(to_cdi-cdi > 0){
            qsort(objects, (to_cdi-cdi+1), sizeof(int), compare);  
            
            for(int i = 0; i < (to_cdi-cdi); i++){
               difference[i] = objects[i+1] - objects[i];
               if(difference[i] > 0)
                   nz++;
            }

            difference[to_cdi-cdi] = 1;
        }else{
            nz = to_cdi-cdi+1;  
        }

        int objects_to_update[nz];
        if(to_cdi-cdi > 0){
            int j = 1;
            for(int i = 0; i <= (to_cdi-cdi); i++){
                if(difference[i] > 0){
                    objects_to_update[j-1] = objects[i]-1;
                    j++;
                }
            }
        }else{
            for(int i = 0; i <= (to_cdi-cdi); i++){
                objects_to_update[i] = objects[i];
            }
        }


        for(int i = 0; i < nz; i++){
            int n = 1;
            int l = 1;
            double n_hat = 0;
            double n_of_r_neighbors[mt+1];
            for(int j = 0; j < mt; j++){
                if(distmat[objects_to_update[i]+j*m] <= alpha_r){
                    n++;
                }
                if(distmat[objects_to_update[i]+j*m] <= r){
                    n_hat += train_current_alpha_neighborhood_size[j];
                    n_of_r_neighbors[l-1] = train_current_alpha_neighborhood_size[j];
                    l++;
                }
            }
            n_of_r_neighbors[l-1] = n;
            
            n_hat = (n_hat + n)/l;
            double mdef = 1 - (n / n_hat);

            //with 1e-10 we suppress the divide by zero warning
            double std_n_of_r_neighbors = 0;
            for(int k = 0; k < l; k++)
               std_n_of_r_neighbors += pow(n_of_r_neighbors[k] - n_hat, 2);
            std_n_of_r_neighbors = sqrt(std_n_of_r_neighbors/l) + 1e-10;

            double normalized_deviation = std_n_of_r_neighbors / n_hat;
            double k_sigma = mdef / normalized_deviation;

            if(l >= min_n){
                if(k_sigmas[objects_to_update[i]] > k_sigma) 
                    k_sigmas[objects_to_update[i]] = k_sigmas[objects_to_update[i]];
                else
                    k_sigmas[objects_to_update[i]] = k_sigma;
            }

       }


        
        //go to the next critical distance
        cdi = to_cdi + 1;
       // mexPrintf("%d\n", cdi+1);
       // if(cdi > 300){
       //     break;
       // }
    }

    return;
}