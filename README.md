# On the evaluation of outlier detection and one-class classification

Repository of the paper:

```latex
H. O. Marques, L. Swersky, J. Sander, A. Zimek and R. J. G. B. Campello. 
On the Evaluation of Outlier Detection and One-Class Classification: 
A Comparative Study of Algorithms, Model Selection, and Ensembles. 
To appears in: DAMI (2023)
```
### Toolboxes
- [dd_tools](https://www.tudelft.nl/ewi/over-de-faculteit/afdelingen/intelligent-systems/pattern-recognition-bioinformatics/pattern-recognition-bioinformatics/data-and-software/dd-tools) [[1]](#references)</br>
- [PRTools5](http://prtools.tudelft.nl/Guide/37Pages/software.html) [[2]](#references)</br>
- [GLPKmex](http://sourceforge.net/projects/glpkmex/)</br>

#### <a name="importing-toolboxes">Importing toolboxes</a>
After downloading, you can add PRTools5, dd_tools, and GLPKmex toolboxes to the MATLAB workspace using the command ```addpath```:
```addpath('path/to/prtools');``` </br>
```addpath('path/to/dd_tools');```</br>
```addpath('path/to/glpkmex');```

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
However, we also make them available ready-to-use in MATLAB [here](Datasets).</br>

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
As this is a multi-class dataset, we have to transform it into a one-class dataset. It is done by using the dd_tools command ```oc_set```.<br>
You only need to set which class(es) will be the inlier (aka target) class.</br>

Setting class 1 as inlier class:</br>
```oc_data = oc_set(iris2d, [1]);```</br>
```scatterd(oc_data, 'legend');```</br>
<p align="center"><img src="/Figures/oc_iris1.png" width="40%" height="40%"></p>

Setting classes 1 and 2 as inlier class:</br>
```oc_data = oc_set(iris2d, [1 2]);``` </br>
```scatterd(oc_data, 'legend');```</br>
<p align="center"><img src="/Figures/oc_iris12.png" width="40%" height="40%"></p>

- Holdout</br>
In order to partition data into training and testing, we can use the command [gendat](http://www.37steps.com/prhtml/prtools/gendat.html). In the example below, we partition the dataset to use 80% for training and hold 20% to test:</br>
```[train, test] = gendat(oc_data, 0.8);```</br>

### Algorithms
- One-class classification algorithms:
  - Gaussian Mixture Model ([GMM](/Algorithms/gmm_dd.m)) [[7]](#references) </br>
We used MATLAB's own implementation for GMM, we just encapsulated it to follow the same pattern used by the dd_tools classifiers.</br>
    - Training </br>
    ```w = gmm_dd(train, 0, 1);``` </br>
    - Testing </br>
    ```wx = test*w;``` </br>
    ```dd_auc(dd_roc(wx))``` </br>
    ```dd_mcc(wx)``` </br>
    ```dd_precatn(wx)``` </br>
    - Plot </br>
    ```scatterd(oc_data, 'legend');``` </br>
    ```plotd(w)``` </br>
<p align="center"><img src="/Figures/gmm.png" width="40%" height="40%"></p>

  - Parzen Window ([PW](http://homepage.tudelft.nl/n9d04/functions/parzen_dd.html)) [[8]](#references) </br>
We used dd_tools implementation for PW.</br>
      - Training </br>
    ```w = parzen_dd(train, 0, 0.25);``` </br>
    - Testing </br>
    ```wx = test*w;``` </br>
    ```dd_auc(dd_roc(wx))``` </br>
    ```dd_mcc(wx)``` </br>
    ```dd_precatn(wx)``` </br>
    - Plot </br>
    ```scatterd(oc_data, 'legend');``` </br>
    ```plotd(w)``` </br>
<p align="center"><img src="/Figures/pw.png" width="40%" height="40%"></p>

  - Support Vector Data Description ([SVDD](/Algorithms/libsvdd.m)) [[9]](#references) </br>
We used [LIBSVM](https://www.csie.ntu.edu.tw/~cjlin/libsvmtools/#libsvm_for_svdd_and_finding_the_smallest_sphere_containing_all_data)[[21]](#references) implementation in C++ for SVDD due to the computational burden. We encapsulated it to follow the same pattern used by the dd_tools classifiers.</br>
As this is a C++ implementation, you must compile it before its first use. Make sure a supported compiler is installed on the machine.
      - Compiling </br>
      ```mex -setup;``` </br>
      ```make``` </br>
      For general troubleshooting, read the LIBSVM [README](/Algorithms/libsvm/matlab/README) file.
      - Training </br>
    ```w = libsvdd(train, 0, 1);``` </br>
    - Testing </br>
    ```wx = test*w;``` </br>
    ```dd_auc(dd_roc(wx))``` </br>
    ```dd_mcc(wx)``` </br>
    ```dd_precatn(wx)``` </br>
    - Plot </br>
    ```scatterd(oc_data, 'legend');``` </br>
    ```plotd(w)``` </br>
<p align="center"><img src="/Figures/svdd.png" width="40%" height="40%"></p>

  - Linear Programming ([LP](http://homepage.tudelft.nl/n9d04/functions/lpdd.html)) [[10]](#references) </br>
We used dd_tools implementation for LP.</br>
      - Training </br>
    ```w = lpdd(target_class(train), 0, 0.25);``` </br>
    - Testing </br>
    ```wx = test*w;``` </br>
    ```dd_auc(dd_roc(wx))``` </br>
    ```dd_mcc(wx)``` </br>
    ```dd_precatn(wx)``` </br>
    - Plot </br>
    ```scatterd(oc_data, 'legend');``` </br>
    ```plotc(w)``` </br>
<p align="center"><img src="/Figures/lpdd.png" width="40%" height="40%"></p>

  - k-Nearest Neighbor Data Description ([kNN<sub>local</sub>](/Algorithms/lknn.m)) [[11]](#references) </br>
We used MATLAB's own implementation for GMM, we just encapsulated it to follow the same pattern used by the dd_tools classifiers.</br>
      - Training </br>
    ```w = gmm_dd(train, 0, 1);``` </br>
    - Testing </br>
    ```wx = test*w;``` </br>
    ```dd_auc(dd_roc(wx))``` </br>
    ```dd_mcc(wx)``` </br>
    ```dd_precatn(wx)``` </br>
    - Plot </br>
    ```scatterd(oc_data, 'legend');``` </br>
    ```plotd(w)``` </br>
<p align="center"><img src="/Figures/gmm.png" width="40%" height="40%"></p>

  - [Auto-Encoder](http://homepage.tudelft.nl/n9d04/functions/autoenc_dd.html) [[12]](#references) </br>
We used MATLAB's own implementation for GMM, we just encapsulated it to follow the same pattern used by the dd_tools classifiers.</br>
      - Training </br>
    ```w = gmm_dd(train, 0, 1);``` </br>
    - Testing </br>
    ```wx = test*w;``` </br>
    ```dd_auc(dd_roc(wx))``` </br>
    ```dd_mcc(wx)``` </br>
    ```dd_precatn(wx)``` </br>
    - Plot </br>
    ```scatterd(oc_data, 'legend');``` </br>
    ```plotd(w)``` </br>
<p align="center"><img src="/Figures/gmm.png" width="40%" height="40%"></p>

  - Deep SVDD ([DSVDD]()) [[13]](#references) </br>
We used MATLAB's own implementation for GMM, we just encapsulated it to follow the same pattern used by the dd_tools classifiers.</br>
      - Training </br>
    ```w = gmm_dd(train, 0, 1);``` </br>
    - Testing </br>
    ```wx = test*w;``` </br>
    ```dd_auc(dd_roc(wx))``` </br>
    ```dd_mcc(wx)``` </br>
    ```dd_precatn(wx)``` </br>
    - Plot </br>
    ```scatterd(oc_data, 'legend');``` </br>
    ```plotd(w)``` </br>
<p align="center"><img src="/Figures/gmm.png" width="40%" height="40%"></p>

- Unsupervised outlier detection algorithms adapted to one-class classification
  - k-Nearest Neighbors (kNN<sub>global</sub>) [[14]](#references) </br>
  - Local Outlier Factor (LOF) [[15]](#references) </br>
  - Local Correlation Integral (LOCI) [[16]](#references) </br>
  - Global-Local Outlier Scores from Hierarchies (GLOSH) [[17]](#references) </br>
  - Isolation Forest (iForest) [[18]](#references) </br>
  - Angle-Based Outlier Detection (ABOD) [[19]](#references) </br>
  - Subspace Outlier Degree (SOD) [[20]](#references) </br>


### Model Selection

### Ensembles


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

