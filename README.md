# On the Evaluation of Outlier Detection and One-Class Classification

Repository of the paper:

```latex
H. O. Marques, L. Swersky, J. Sander, A. Zimek and R. J. G. B. Campello. 
On the Evaluation of Outlier Detection and One-Class Classification: 
A Comparative Study of Algorithms, Model Selection, and Ensembles. 
DAMI (2023)
```

This repository only intends to provide the source code used in our experiments and instructions on how to use them. </br>
For details about the algorithms, properties, and parameters, consult our [supplementary material](https://homarques.github.io/occ/SupplementaryMaterial/Algorithms.pdf).

### Toolboxes
- [dd_tools](https://www.tudelft.nl/ewi/over-de-faculteit/afdelingen/intelligent-systems/pattern-recognition-bioinformatics/pattern-recognition-bioinformatics/data-and-software/dd-tools) [[1]](#references)</br>
- [PRTools5](http://prtools.tudelft.nl/Guide/37Pages/software.html) [[2]](#references)</br>
- [GLPKmex](http://sourceforge.net/projects/glpkmex/)</br>

#### <a name="importing-toolboxes">Importing toolboxes</a>
After downloading, you can add PRTools5, dd_tools, and GLPKmex<sup>*</sup> toolboxes to the MATLAB workspace using the command ```addpath```: </br>
```addpath('path/to/prtools');``` </br>
```addpath('path/to/dd_tools');```</br>
```addpath('path/to/GLPKmex');```</br>

<sup>*</sup>GLPKmex is only needed to use the [LP](#lp) classifier.

------

### Datasets
- Synthetic datasets [[3]](#references)
  - [synth-batch1](http://www.dbs.ifi.lmu.de/~zimek/publications/KDD2013/synthetic.tar.gz)</br>

- [UCI datasets](https://archive.ics.uci.edu/ml/index.php) [[4]](#references)
  - [Pre-processed by Tax:](http://homepage.tudelft.nl/n9d04/occ/index.html) Abalone, Arrhythmia, Balance-scale, Ball-bearing, Biomed, Breast, Cancer, Colon, Delft1x3, Delft2x2, Delft3x2, Delft5x1, Delft5x3, Diabetes, Ecoli, Glass, Heart, Hepatitis, Housing, Imports, Ionosphere, Iris, Liver, Satellite, Sonar, Spectf, Survival, Vehicle, Vowels, Waveform, and Wine. <br>
  - **Pre-processed by ourselves:** Artificial Characters, Cardiotocography, Car Evaluation, CNAE-9, Dermatology, Solar Flare, Hayes-Roth, LED Display, Lung Cancer, Multiple Features, Optical Recognition, Page Blocks, Seeds, Semeion, Soybean, Synthetic Control, Texture, User Knowledge Modeling, Vertebra Column, and Zoo. <br>

- Other datasets
  - [CellCycle-237](http://faculty.washington.edu/kayee/cluster/normcho_237_4class.txt) [[5]](#references) and [YeastGalactose](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC156590/bin/gb-2003-4-5-r34-s8.txt) [[6]](#references)

#### Manipulating datasets
We provide above the original source of all datasets used in our experiments.</br>
For convenience, we also make them available ready-to-use in MATLAB [here](Datasets).</br>

- Reading datasets</br>
After downloading, you can load the datasets to the MATLAB workspace using the command ```load```, just make sure you already [imported](#importing-toolboxes) PRTools5 to your workspace before: </br>
```load('Datasets/Real/iris.mat');``` </br>

- Scatterplots</br>
After loading the dataset, you can plot it using the command [scatterd](http://www.37steps.com/prhtml/prtools/scatterd.html) to get some feeling about the distribution of datasets.<br>
As this dataset is 4-dimensional, first, we will project it in a 2D space using PCA with the command [pcam](http://www.37steps.com/prhtml/prtools/pcam.html): </br>
```iris2d = data*pcam(data,2);```</br>
```scatterd(iris2d);```</br>
<p align="center"><img src="/Figures/iris2d.png" width="40%" height="40%"></p>

- Creating one-class datasets</br>
	As this is a multi-class dataset, we have to transform it into a one-class dataset. It is done by using the dd_tools command [oc_set](https://homepage.tudelft.nl/n9d04/functions/oc_set.html).<br>
	You only need to set which class(es) will be the inlier (aka target) class.</br>

	Setting class 1 as inlier class:</br>
	```oc_data = oc_set(iris2d, [1]);```</br>
	```scatterd(oc_data, 'legend');```</br>
	<p align="center"><img src="/Figures/oc_iris1.png" width="40%" height="40%"></p>

- Holdout</br>
In order to partition data into training and testing, we can use the command [gendat](http://www.37steps.com/prhtml/prtools/gendat.html). In the example below, we partition the dataset to use 80% for training and hold 20% to test:</br>
```[train, test] = gendat(oc_data, 0.8);```</br>

### Algorithms
The algorithms provided here follow the dd_tools pattern. </br>
Usually, the first parameter is the training dataset, the second is the percentage of the dataset that can be misclassified during the training, and the third is the algorithm's parameter. </br>
Note that some algorithms have no parameter, and others have more than one. </br>

- One-class classification algorithms:
  - Gaussian Mixture Model ([GMM](/Algorithms/gmm_dd.m)) [[7]](#references) </br>
    We use MATLAB's own implementation for GMM, we just encapsulated it to follow the same pattern used by the dd_tools classifiers.</br>
    - Training </br>
      ```w = gmm_dd(target_class(train), 0, 1);``` </br>
    - Plot </br>
      ```scatterd(oc_data, 'legend');``` </br>
      ```plotc(w)``` </br>
    <p align="center"><img src="/Figures/gmm.png" width="40%" height="40%"></p>

  - Parzen Window ([PW](http://homepage.tudelft.nl/n9d04/functions/parzen_dd.html)) [[8]](#references) </br>
    We use dd_tools implementation for PW.</br>
    - Training </br>
      ```w = parzen_dd(target_class(train), 0, 0.25);``` </br>
    - Plot </br>
      ```scatterd(oc_data, 'legend');``` </br>
      ```plotc(w)``` </br>
    <p align="center"><img src="/Figures/pw.png" width="40%" height="40%"></p>

  - Support Vector Data Description ([SVDD](/Algorithms/libsvdd.m)) [[9]](#references) </br>
    We use [LIBSVM](https://www.csie.ntu.edu.tw/~cjlin/libsvmtools/#libsvm_for_svdd_and_finding_the_smallest_sphere_containing_all_data)[[21]](#references) implementation in C++ for SVDD due to the computational burden. We encapsulated it to follow the same pattern used by the dd_tools classifiers.</br>
    As this is a C++ implementation, you must compile it before its first use. Make sure a [supported compiler](https://se.mathworks.com/support/requirements/supported-compilers.html) is installed on the machine.
    - Compiling </br>
      ```mex -setup;``` </br>
      ```make``` </br>
      For general troubleshooting, read the LIBSVM [README](/Algorithms/libsvm/matlab/README) file.
    - Training </br>
      ```w = libsvdd(target_class(train), 0, 1);``` </br>
    - Plot </br>
      ```scatterd(oc_data, 'legend');``` </br>
      ```plotc(w)``` </br>
    <p align="center"><img src="/Figures/svdd.png" width="40%" height="40%"></p>

  - <a name="lp"> Linear Programming ([LP](http://homepage.tudelft.nl/n9d04/functions/lpdd.html)) [[10]](#references) </a> </br>
    We use dd_tools implementation for LP.</br>
    - Training </br>
      ```w = lpdd(target_class(train), 0, 0.25);``` </br>
    - Plot </br>
      ```scatterd(oc_data, 'legend');``` </br>
      ```plotc(w)``` </br>
    <p align="center"><img src="/Figures/lpdd.png" width="40%" height="40%"></p>

  - k-Nearest Neighbor Data Description ([kNN<sub>local</sub>](/Algorithms/lknndd.m)) [[11]](#references) </br>
    We use our own implementation for kNN<sub>local</sub>, following the same pattern used by the dd_tools classifiers.</br>
    - Training </br>
      ```w = lknndd(target_class(train), 0, 1);``` </br>
    - Plot </br>
      ```scatterd(oc_data, 'legend');``` </br>
      ```plotc(w)``` </br>
    <p align="center"><img src="/Figures/lknn.png" width="40%" height="40%"></p>

  - [Auto-Encoder](http://homepage.tudelft.nl/n9d04/functions/autoenc_dd.html) [[12]](#references) </br>
    We use dd_tools implementation for Auto-Encoder.</br>
    - Training </br>
      ```w = autoenc_dd(target_class(train), 0, 10);``` </br>
    - Plot </br>
      ```scatterd(oc_data, 'legend');``` </br>
      ```plotc(w)``` </br>
    <p align="center"><img src="/Figures/autoenc.png" width="40%" height="40%"></p>

  - Deep SVDD ([DSVDD](/Algorithms/dsvdd.m)) [[13]](#references) </br>
    For DSVDD, we use the [authors' implementation](https://github.com/lukasruff/Deep-SAD-PyTorch) in Python, we made some small adjustments to communicate to MATLAB and encapsulated it to follow the same pattern used by the dd_tools classifiers.</br>
    Since the implementation is in Python, make sure you have a compatible version of Python and all the required packages installed.</br>
    The list of packages required, you can find [here](/Algorithms/Deep-SAD-PyTorch/requirements.txt).</br>
    Also, make sure your Python environment is setup up on MATLAB. If not, [check this out](https://se.mathworks.com/help/matlab/ref/pyenv.html).</br>

    - Add Python source to MATLAB env </br>
      ```pathToSAD = fileparts('path/to/Deep-SAD-PyTorch/src/main.py');``` </br> 
      ```insert(py.sys.path, int32(0), pathToSAD)``` </br>
    - Training </br>
      ```w = dsvdd(target_class(train), 0, 8);``` </br>
    - Plot </br>
      ```scatterd(oc_data, 'legend');``` </br>
      ```plotc(w)``` </br>
    <p align="center"><img src="/Figures/dsvdd.png" width="40%" height="40%"></p>

- Unsupervised outlier detection algorithms adapted to one-class classification
  - k-Nearest Neighbors ([kNN<sub>global</sub>](https://homepage.tudelft.nl/n9d04/functions/knndd.html)) [[14]](#references) </br>
    We use dd_tools implementation for kNN<sub>global</sub>.</br>
    - Training </br>
      ```w = knndd(target_class(train), 0, 1);``` </br>
    - Plot </br>
      ```scatterd(oc_data, 'legend');``` </br>
      ```plotc(w)``` </br>
    <p align="center"><img src="/Figures/knn.png" width="40%" height="40%"></p>

  - Local Outlier Factor ([LOF](/Algorithms/lof.m)) [[15]](#references) </br>
    We use our own implementation for LOF in order to reuse the pre-computed quantities related to instances in the training data. The implementation follows the same pattern used by the dd_tools classifiers.
    - Training </br>
      ```w = lof(target_class(train), 0, 10);``` </br>
    - Plot </br>
      ```scatterd(oc_data, 'legend');``` </br>
      ```plotc(w)``` </br>
    <p align="center"><img src="/Figures/lof.png" width="40%" height="40%"></p>

  - Local Correlation Integral ([LOCI](/Algorithms/loci.m)) [[16]](#references) </br>
    We use our own implementation for LOCI in order to reuse the pre-computed quantities related to instances in the training data. The implementation follows the same pattern used by the dd_tools classifiers.
    - Training </br>
      ```w = loci(target_class(train), 0, 0.1);``` </br>
    - Plot </br>
      ```scatterd(oc_data, 'legend');``` </br>
      ```plotc(w)``` </br>
    <p align="center"><img src="/Figures/loci.png" width="40%" height="40%"></p>

  - Global-Local Outlier Scores from Hierarchies ([GLOSH](/Algorithms/gloshdd.m)) [[17]](#references) </br>
    We use the authors' implementation in Java for GLOSH. We also encapsulated it to follow the same pattern used by the dd_tools classifiers.</br>
    Since the implementation is in Java, first, we need to import the Java source to the MATLAB environment:</br>
    - Add Java source to MATLAB env </br>
      ```javaaddpath Algorithms/GLOSH/GLOSHDD.jar ```</br>
      ```import ca.ualberta.cs.hdbscanstar.* ```</br>
    - Training </br>
      ```w = gloshdd(target_class(train), 0, 5);``` </br>
    - Plot </br>
      ```scatterd(oc_data, 'legend');``` </br>
      ```plotc(w)``` </br>
    <p align="center"><img src="/Figures/glosh.png" width="40%" height="40%"></p>

  - Isolation Forest ([iForest](/Algorithms/iforest_dd.m)) [[18]](#references) </br>
    For iForest, we use a [third-part](https://github.com/zhuye88/iForest) MATLAB implementation. We just encapsulated it to follow the same pattern used by the dd_tools classifiers.</br>
    - Training </br>
      ```w = iforest_dd(target_class(train), 0, 256, 60);``` </br>
    - Plot </br>
      ```scatterd(oc_data, 'legend');``` </br>
      ```plotc(w)``` </br>
    <p align="center"><img src="/Figures/iforest.png" width="40%" height="40%"></p>

  - Angle-Based Outlier Detection ([ABOD](https://homepage.tudelft.nl/n9d04/functions/abof_dd.html)) [[19]](#references) </br>
    We use dd_tools implementation for ABOD.</br>
    - Training </br>
      ```w = abof_dd(target_class(train), 0);``` </br>
    - Plot </br>
      ```scatterd(oc_data, 'legend');``` </br>
      ```plotc(w)``` </br>
    <p align="center"><img src="/Figures/abod.png" width="40%" height="40%"></p>

  - Subspace Outlier Degree ([SOD](/Algorithms/sod.m)) [[20]](#references) </br>
    For SOD, we use our own implementation based on [ELKI](https://elki-project.github.io/)[[22]](#references) implementation. We also encapsulated it to follow the same pattern used by the dd_tools classifiers.</br>
    - Training </br>
      ```w = sod(target_class(train), 0, 10);``` </br>
    - Plot </br>
      ```scatterd(oc_data, 'legend');``` </br>
      ```plotc(w)``` </br>
    <p align="center"><img src="/Figures/sod.png" width="40%" height="40%"></p>

### Measures
Once the classifier is trained, we can compute its performance using different measures. </br>
We use the following performance measures in our experiments: </br>
  - Area Under the ROC Curve ([ROC AUC](https://homepage.tudelft.nl/n9d04/functions/dd_roc.html)) [[23]](#references) </br>
  ```dd_auc(dd_roc(test*w));```</br>
  - Adjusted Precision-at-n ([AdjustedPrec@n](/Measures/dd_precatn.m)) [[23]](#references) </br>
  ```dd_precatn(test*w);```</br>
  - Matthews Correlation Coefficient ([MCC](/Measures/dd_mcc.m)) [[24]](#references) </br>
  ```dd_mcc(test*w);```</br>

### Model Selection
  - [Cross-validation](http://homepage.tudelft.nl/n9d04/functions/dd_crossval.html) [[25]](#references) (supervised) </br>
    ```matlab
    nrfolds = 10;
    err = zeros(nrfolds, 1);
    I = nrfolds;
    for j=1:nrfolds
        %x - training set, z - test set
        [x,z,I] = dd_crossval(train, I);
        %training
        w = gmm_dd(x, 0, 1);
        %test
        err(j) = dd_auc(dd_roc(z*w));
    end
    mean(err)
    ```
  - Self-adaptive Data Shifting ([SDS](/MS/sds.m)) [[26]](#references) (unsupervised) </br>
    - Generation of data: </br>
  ```[sds_targets, sds_outliers] = sds(target_class(train));```</br>
  
    - Classifier error: </br>
	     ```matlab
		  % Error on target class
		  err_t = dd_error(sds_targets*w);

		  % Error on outlier class
		  err_o = dd_error(sds_outliers*w);

		  % classifier error
		  err_sds = err_t(1) + err_o(2);
	     ```
  
  - [Perturbation](/MS/perturbation.m) [[27]](#references) (unsupervised) </br>
    - Generation of data: </br>
  ```nrinst = 20;```</br>
  ```pert_targets = perturbation(target_class(train), nrinst, 0.5);```</br>
  
    - Classifier error: </br>
	    ```matlab
	    % Error on target class (cross-validation without outliers)
	    nrfolds = 10;
	    err_t = zeros(nrfolds, 1);
	    I = nrfolds;
	    for j = 1:nrfolds
		%x - training set, z - test set
		[x,z,I] = dd_crossval(target_class(train), I);
		%training
		w = gmm_dd(x, 0, 1);
		%test
		err_xval = dd_error(z, w);
		err_t(j) = err_xval(1);
	    end

	    % Error on outlier class (perturbed data)
	    err_o = zeros(nrinst, 1);
	    for j = 1:nrinst
	      err_pert = dd_error(pert_targets{j}*w);
	      err_o(j) = err_pert(2);
	    end

	    % classifier error
	    err_pert = mean(err_t) + mean(err_o);
	    ```

  - [Uniform Objects](https://homepage.tudelft.nl/n9d04/functions/gendatout.html) [[28]](#references) (unsupervised) </br>
    - Generation of data: </br>
  ```unif_targets = gendatout(target_class(train), 100000);```</br>
    
    - Classifier error: </br>
	  ```matlab
	    % Error on target class (cross-validation without outliers)
	    nrfolds = 10;
	    err_t = zeros(nrfolds, 1);
	    I = nrfolds;
	    for j = 1:nrfolds
		%x - training set, z - test set
		[x,z,I] = dd_crossval(target_class(train), I);
		%training
		w = gmm_dd(x, 0, 1);
		%test
		err_xval = dd_error(z, w);
		err_t(j) = err_xval(1);
	    end

	    % Error on outlier class (uniform data)
	    err_o = dd_error(unif_targets*w);

	    % classifier error
	    err_unif = mean(err_t) + err_o(2);
	   ```

### Ensembles
  - Reciprocal Rank Fusion ([RRF](/Ensembles/RRF_dd.m)) [[29]](#references)
	```matlab
	ranks = zeros(size(test,1),3);
	
	%training GMM
	w = gmm_dd(target_class(train), 0, 1);
	wx = test*w;
	ranks(:,1) = +wx(:,1);

	%training KNN
	w = knndd(target_class(train), 0, 1);
	wx = test*w;
	ranks(:,2) = +wx(:,1);
	
	%training LOF
	w = lof(target_class(train), 0, 10);
	wx = test*w;
	ranks(:,3) = +wx(:,1);

	% Combining rankings
	ranks = tiedrank(ranks);
	w = RRF_dd(train, 0, ranks);
	dd_auc(dd_roc(test*w));
	```

## <a name="references">References</a>
[1] D. M. J. Tax: DDtools, the Data Description Toolbox for Matlab. Version 2.1.3, Delft University of Technology, 2018<br>
[2] R. P. W. Duin, P. Juszczak, P. Paclik, E. Pekalska, D. de Ridder, D. M. J. Tax, S. Verzakov: PRTools: A Matlab Toolbox for Pattern Recognition. Version 5.4.2, Delft University of Technology, 2018<br>
[3] A. Zimek, M. Gaudet, R. J. G. B. Campello, J. Sander: Subsampling for Efficient and Effective Unsupervised Outlier Detection Ensembles. SIGKDD, 2013.<br>
[4] D. Dua, C. Graff: UCI Machine Learning Repository. University of California, 2019. <br>
[5] K. Y. Yeung, C. Fraley, A. Murua, A. E. Raftery, W. L. Ruzzo: Model-Based Clustering and Data Transformations for Gene Expression Data. Bioinformatics,  2001. <br>
[6] K. Y. Yeung, M. Medvedovic, R. E. Bumgarner: Clustering Gene-Expression Data with Repeated Measurements. Genome Biology, 2003. <br>
[7] C. M. Bishop: Pattern Recognition and Machine Learning. Springer, 2006. <br>
[8] E. Parzen: On Estimation of a Probability Density Function and Mode. The Annals of Mathematical Statistics, 1962. <br>
[9] D. M. J. Tax, R. P. W. Duin: Support Vector Data Description. Machine Learning, 2004. <br>
[10] E. Pekalska, D. M. J. Tax, R. P. W. Duin: One-Class LP Classifiers for Dissimilarity Representations. NIPS, 2002. <br>
[11] D. de Ridder, D. M. J. Tax, R. P. W. Duin: An Experimental Comparison of One-Class Classification Methods. ASCI, 1998. <br>
[12] N. Japkowicz, C. Myers, M. A. Gluck: A Novelty Detection Approach to Classification. IJCAI, 1995. <br>
[13] L. Ruff, N. Görnitz, L. Deecke, S. A. Siddiqui, A. Binder, E. Müller, M. Kloft: Deep One-Class Classification. ICML, 2018. <br>
[14] S. Ramaswamy, R. Rastogi, K. Shim: Efficient Algorithms for Mining Outliers from Large Data Sets. SIGMOD, 2000. <br>
[15] M. M. Breunig, H. Kriegel, R. T. Ng, J. Sander: LOF: Identifying Density-Based Local Outliers. SIGMOD, 2000. <br>
[16] S. Papadimitriou, H. Kitagawa, P. B. Gibbons, C. Faloutsos: LOCI: Fast Outlier Detection using the Local Correlation Integral. ICDE, 2003. <br>
[17] R. J. G. B. Campello, D. Moulavi, A. Zimek, J. Sander: Hierarchical Density Estimates for Data Clustering, Visualization, and Outlier Detection. TKDD, 2015. <br>
[18] F. T. Liu, K. M. Ting, Z. Zhou: Isolation-Based Anomaly Detection. TKDD, 2012. <br>
[19] H. Kriegel, M. Schubert, A. Zimek: Angle-Based Outlier Detection in High-Dimensional Data. SIGKDD, 2008. <br>
[20] H. Kriegel, P. Kröger, E. Schubert, A. Zimek: Outlier Detection in Axis-Parallel Subspaces of High Dimensional Data. PAKDD, 2009. <br>
[21] C.-C. Chang, C.-J. Lin: LIBSVM: A Library for Support Vector Machines. TIST, 2011. <br>
[22] E. Schubert, A. Zimek: ELKI: A large open-source library for data analysis. ELKI Release 0.7.5, CoRR arXiv 1902.03616, 2019. <br>
[23] G. O. Campos, A. Zimek, J. Sander, R. J. G. B. Campello, B. Micenková, E. Schubert, I. Assent, M. E. Houle: On the Evaluation of Unsupervised Outlier Detection: Measures, Datasets, and an Empirical Study. DAMI, 2016. <br>
[24] B. W. Matthews: Comparison of the Predicted and Observed Secondary Structure of T4 Phage Lysozyme. BBA, 1975. <br>
[25] J. Han, M. Kamber, J. Pei: Data Mining: Concepts and Techniques. Morgan Kaufmann, 2011. <br>
[26] S. Wang, Q. Liu, E. Zhu, F. Porikli, J. Yin: Hyperparameter Selection of One-Class Support Vector Machine by Self-Adaptive Data Shifting. Pattern Recognition, 2018. <br>
[27] H. O. Marques: Evaluation and Model Selection for Unsupervised Outlier Detection and One-Class Classification. PhD thesis, University of São Paulo, 2011. <br>
[28] D. M. J. Tax, R. P. W. Duin: Uniform Object Generation for Optimizing One-class Classifiers. JMLR, 2001. <br>
[29] G. V. Cormack, C. L. A. Clarke, S Büttcher: Reciprocal Rank Fusion Outperforms Condorcet and Individual Rank Learning Methods. SIGIR, 2009. <br>
