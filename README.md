# On the evaluation of outlier detection and one-class classification

Repository of the paper:

```latex
H. O. Marques, L. Swersky, J. Sander, A. Zimek and R. J. G. B. Campello. 
On the Evaluation of Outlier Detection and One-Class Classification: 
A Comparative Study of Algorithms, Model Selection, and Ensembles. 
To appears in: DAMI (2023)
```
### Third-party codes & data
#### Toolboxes
- [dd_tools](https://www.tudelft.nl/ewi/over-de-faculteit/afdelingen/intelligent-systems/pattern-recognition-bioinformatics/pattern-recognition-bioinformatics/data-and-software/dd-tools) [[1]](#references)<br>
- [PRTools5](http://prtools.tudelft.nl/Guide/37Pages/software.html) [[2]](#references)<br>

##### <a name="importing-toolboxes">Importing toolboxes</a>
After downloading, you can add PRTools5 and dd_tools toolboxes to the MATLAB workspace using the command ```addpath```:
```addpath('path/to/prtools');``` </br>
```addpath('path/to/dd_tools');```

#### Datasets
- Synthetic datasets [[3]](#references)
  - [synth-batch1](http://www.dbs.ifi.lmu.de/~zimek/publications/KDD2013/synthetic.tar.gz)<br>

- [UCI datasets](https://archive.ics.uci.edu/ml/index.php) [[4]](#references)
  - [Pre-processed by Tax:](http://homepage.tudelft.nl/n9d04/occ/index.html) Abalone, Arrhythmia, Balance-scale, Ball-bearing, Biomed, Breast, Cancer, Colon, Delft1x3, Delft2x2, Delft3x2, Delft5x1, Delft5x3, Diabetes, Ecoli, Glass, Heart, Hepatitis, Housing, Imports, Ionosphere, Iris, Liver, Satellite, Sonar, Spectf, Survival, Vehicle, Vowels, Waveform, and Wine. <br>
  - **Pre-processed by ourselves:** Artificial Characters, Cardiotocography, Car Evaluation, CNAE-9, Dermatology, Solar Flare, Hayes-Roth, LED Display, Lung Cancer, Multiple Features, Optical Recognition, Page Blocks, Seeds, Semeion, Soybean, Synthetic Control, Texture, User Knowledge Modeling, Vertebra Column, and Zoo. <br>

- Other datasets
  - [CellCycle-237](http://faculty.washington.edu/kayee/cluster/normcho_237_4class.txt) [[5]](#references) and [YeastGalactose](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC156590/bin/gb-2003-4-5-r34-s8.txt) [[6]](#references)

##### Manipulating datasets
We provide above the original source of all datasets used in our experiments.<br>
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
<p align="center"><img src="/Figures/oc_iris1.png" width="40%" height="40%"></p>

Setting classes 1 and 2 as inlier class:</br>
```oc_data = oc_set(iris2d, [1 2]);``` </br>
<p align="center"><img src="/Figures/oc_iris12.png" width="40%" height="40%"></p>

- Holdout</br>
In order to partition data into training and testing, we can use the command [gendat](http://www.37steps.com/prhtml/prtools/gendat.html). In the example below, we partition the dataset to use 80% for training and hold 20% to test:</br>
```[train, test] = gendat(oc_data, 0.8);```</br>

#### Algorithms
- One-class classification algorithms
  - Gaussian Mixture Model (GMM), Parzen Window (PW), Support Vector Data Description (SVDD), Linear Programming (LP), k-Nearest Neighbor Data Description  (kNN<sub>local</sub>), Auto-Encoder, and Deep SVDD (DSVDD).

- Unsupervised outlier detection algorithms adapted to one-class classification
  - k-Nearest Neighbors (kNN<sub>global</sub>), Local Outlier Factor (LOF), Local Correlation Integral (LOCI), Global-Local Outlier Scores from Hierarchies (GLOSH), Isolation Forest (iForest), Angle-Based Outlier Detection (ABOD), and Subspace Outlier Degree (SOD).

#### Model Selection

#### Ensembles


## <a name="references">References</a>
[1] D. M. J. Tax: DDtools, the Data Description Toolbox for Matlab. Version 2.1.3, Delft University of Technology, 2018<br>
[2] R. P. W. Duin, P. Juszczak, P. Paclik, E. Pekalska, D. de Ridder, D. M. J. Tax, S. Verzakov: PRTools: A Matlab Toolbox for Pattern Recognition. Version 5.4.2, Delft University of Technology, 2018<br>
[3] A. Zimek, M. Gaudet, R. J. G. B. Campello, J. Sander: Subsampling for Efficient and Effective Unsupervised Outlier Detection Ensembles. SIGKDD, 2013.<br>
[4] D. Dua, C. Graff: UCI Machine Learning Repository. University of California, 2019. <br>
[5] K. Y. Yeung, C. Fraley, A. Murua, A. E. Raftery, W. L. Ruzzo: Model-Based Clustering and Data Transformations for Gene Expression Data. Bioinformatics,  2001. <br>
[6] K. Y. Yeung, M. Medvedovic, R. E. Bumgarner: Clustering Gene-Expression Data with Repeated Measurements. Genome Biology, 2003. <br>

