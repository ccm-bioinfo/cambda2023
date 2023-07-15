
# Prerequisites
- The list of library prerequisites will be stored in the file named [requirements](https://github.com/nselem/ccm-bioinfomatica-lab/tree/main/Hackaton_junio2023/CodigoDanielS/requirements.txt).
- Regarding input data, the code is prepared to receive the list of otus in the folders 01_preprocessing and 02_variable_selection

# Workflow

![image](aux/workFlow.png)

The workflow is designed with two stages of processing, where stage zero integrates the initial data acquired from the otus tables.

## data_classify_with_preselection.py

This code was created to make a complete pipeline of variable selection, data preprosessing, k-folds selection and data training-validation.

The beggining of the pipeline starts with the 5-folds selection, after that, for each fold there is a trainning-validation process taking the selected fold as a validation set and the other four folds as a trainning set.

The trainning is started with the negative-binomial data selection, after that we use a quantile transformer included on sklean to transform the input data by city and finally we 

## data_enrichment.py
The first processing stage integrates with the data normalization codes, which are preprocessed through two different paths.
Normalization using standard scikit-learn algorithms, including MinMaxScaler, Normalizer, OneHotEncoder, OrdinalEncoder, PowerTransformer, QuantileTransformer, RobustScaler, and StandardScaler.
Normalization based on base 10 logarithm plus one to handle errors with the logarithm of zero. This strategy was followed both with and without parameter selection using PCA.

Additionally, the code includes data enrichment using SMOTE codes, a library for enriching imbalanced data.
The enriched dataset was ultimately not used in the final pipeline due to data bias it introduces, as the enrichment was performed before separating into test and validation sets.

## data_classify.py
The second processing stage integrates the classification and model evaluation codes. These codes are prepared to validate a list of models against the preprocessed data in the search for comparison of results.

Each algorithm chosen within this code was selected through additional tests conducted by team members.
The codes, except for the one corresponding to Dr. Balanzario, can be found in the folder [other_codes](https://github.com/nselem/ccm-bioinfomatica-lab/tree/main/Hackaton_junio2023/CodigoDanielS/other_codes).

## other_codes
Here, all the working codes followed during the hackathon process are grouped. Virtually all the developed ideas are already integrated into the main code. They are included as additional reference.

## Extras
Additionally, a related code ([data_fetch.py](https://github.com/nselem/ccm-bioinfomatica-lab/tree/main/Hackaton_junio2023/CodigoDanielS/data_fetch.py)) for data acquisition from NCBI is included. This code was not completed due to an error and lack of time. However, it can be extended from here to automate data downloads.

# Selected pipeline results

This selected pipeline is described at the beginning of [data_classify_with_preselection.py](https://github.com/ccm-bioinfo/cambda2023/tree/main/03_classification/data_classify_with_preselection.py).

This code was selected to verify the results of the simulations, including the complete data selection process to evaluate the overfitting risk.

## Fold 0
Validation results:
  - Number of training samples: 292
  - Number of validation samples: 73
    - Ratio of training samples: 0.8
    - Number of correct predictions: 72
    - Number of incorrect predictions: 1
  - Accuracy: 0.9863013698630136
  - Balanced accuracy: 0.9791666666666666
  - F1 score: 0.9852919971160777

# Results


## reads_kingdoms_zip
```
                               Source  F1-score  Accuracy Pre-preprocess       Preprocess  Algorithm
reads_kingdoms_zip_integrated_reduced     92.84     93.69     transposed PowerTransformer svc_linear
reads_kingdoms_zip_integrated_reduced     90.12     91.50     transposed PowerTransformer   mlpc_200
```


## readsEukarya_count
```
                    Source  F1-score  Accuracy Pre-preprocess Preprocess        Algorithm
 readsEukarya_count__Genus     27.14     27.94       original  LogAndPca randomForest_500
 readsEukarya_count__Genus     26.88     27.94       original  LogAndPca randomForest1200
readsEukarya_count__Family     25.66     27.67       original  LogAndPca randomForest1200
readsEukarya_count__Family     25.29     27.12       original  LogAndPca randomForest_500
readsEukarya_count__Phylum     24.43     28.21       original  LogAndPca         mlpc_200
readsEukarya_count__Phylum     24.17     26.57       original  LogAndPca randomForest1200
 readsEukarya_count__Class     22.84     25.75       original  LogAndPca            knn_5
 readsEukarya_count__Order     22.17     29.04       original  LogAndPca         mlpc_200
 readsEukarya_count__Class     21.58     27.12       original  LogAndPca         mlpc_200
 readsEukarya_count__Order     20.82     25.47       original  LogAndPca            knn_3
```


## assembly_
```
                   Source  F1-score  Accuracy Pre-preprocess          Preprocess        Algorithm
assembly__best_integrated     84.41     87.67       original           LogAndPca         mlpc_200
assembly__best_integrated     83.28     86.84     transposed    PowerTransformer       svc_linear
  assembly__nb_integrated     82.71     86.30     transposed    PowerTransformer       svc_linear
assembly__zinb_integrated     81.10     84.93       original           LogAndPca         mlpc_200
  assembly__nb_integrated     80.63     85.20       original           LogAndPca         mlpc_200
assembly__zinb_integrated     80.33     84.65     transposed QuantileTransformer randomForest_500
 assembly__zip_integrated     77.56     82.19       original    PowerTransformer         mlpc_200
 assembly__zip_integrated     77.42     82.19       original           LogAndPca         mlpc_200
   assembly__p_integrated     64.70     70.13     transposed    PowerTransformer randomForest1200
   assembly__p_integrated     64.50     70.13     transposed    PowerTransformer randomForest_500
```


## assembly_count
```
                Source  F1-score  Accuracy Pre-preprocess Preprocess        Algorithm
assembly_count__Family     81.49     84.38       original  LogAndPca         mlpc_200
assembly_count__Family     79.90     83.56       original  LogAndPca       svc_linear
 assembly_count__Genus     79.49     83.83       original  LogAndPca       svc_linear
 assembly_count__Genus     76.90     81.64       original  LogAndPca randomForest1200
 assembly_count__Order     75.28     79.17       original  LogAndPca         mlpc_200
 assembly_count__Order     74.27     79.45       original  LogAndPca       svc_linear
 assembly_count__Class     62.08     69.58       original  LogAndPca         mlpc_200
 assembly_count__Class     61.19     68.49       original  LogAndPca          svc_rbf
assembly_count__Phylum     49.82     58.90       original  LogAndPca         mlpc_200
assembly_count__Phylum     48.33     55.89       original  LogAndPca       svc_linear
```


## assemblyAB_count
```
                  Source  F1-score  Accuracy Pre-preprocess Preprocess        Algorithm
assemblyAB_count__Family     80.55     83.01       original  LogAndPca         mlpc_200
 assemblyAB_count__Genus     80.48     83.56       original  LogAndPca         mlpc_200
 assemblyAB_count__Genus     77.38     80.54       original  LogAndPca randomForest1200
assemblyAB_count__Family     75.99     79.72       original  LogAndPca randomForest_500
 assemblyAB_count__Order     72.82     78.63       original  LogAndPca         mlpc_200
 assemblyAB_count__Order     71.89     78.08       original  LogAndPca       svc_linear
 assemblyAB_count__Class     62.73     69.04       original  LogAndPca          svc_rbf
 assemblyAB_count__Class     61.92     69.86       original  LogAndPca         mlpc_200
assemblyAB_count__Phylum     43.16     52.60       original  LogAndPca         mlpc_200
assemblyAB_count__Phylum     42.86     52.87       original  LogAndPca randomForest1200
```


## assemblyEukarya_count
```
                       Source  F1-score  Accuracy Pre-preprocess Preprocess Algorithm
 assemblyEukarya_count__Order     22.93     28.49       original  LogAndPca     knn_5
 assemblyEukarya_count__Order     22.83     27.67       original  LogAndPca     knn_3
 assemblyEukarya_count__Class     22.12     27.39       original  LogAndPca     knn_5
 assemblyEukarya_count__Class     20.41     26.57       original  LogAndPca     knn_3
assemblyEukarya_count__Family     19.30     23.83       original  LogAndPca     knn_5
assemblyEukarya_count__Family     19.23     24.10       original  LogAndPca     knn_3
 assemblyEukarya_count__Genus     19.17     24.10       original  LogAndPca     knn_3
assemblyEukarya_count__Phylum     18.98     24.38       original  LogAndPca     knn_3
 assemblyEukarya_count__Genus     18.80     24.65       original  LogAndPca     knn_5
assemblyEukarya_count__Phylum     18.36     24.93       original  LogAndPca     knn_5
```


## assembly_kingdoms_nb
```
                                 Source  F1-score  Accuracy Pre-preprocess       Preprocess  Algorithm
assembly_kingdoms_nb_integrated_reduced     82.37     85.75     transposed PowerTransformer svc_linear
assembly_kingdoms_nb_integrated_reduced     81.86     85.20       original        LogAndPca   mlpc_200
```


## assembly_kingdoms_p
```
                                Source  F1-score  Accuracy Pre-preprocess          Preprocess  Algorithm
assembly_kingdoms_p_integrated_reduced     59.65     67.12       original           LogAndPca svc_linear
assembly_kingdoms_p_integrated_reduced     59.26     67.12       original QuantileTransformer   mlpc_200
```


## reads_kingdoms
```
                        Source  F1-score  Accuracy Pre-preprocess          Preprocess        Algorithm
  reads_kingdoms_nb_integrated     95.51     96.16     transposed    PowerTransformer         mlpc_200
  reads_kingdoms_nb_integrated     95.50     96.43     transposed    PowerTransformer       svc_linear
reads_kingdoms_best_integrated     95.12     95.89     transposed QuantileTransformer       svc_linear
reads_kingdoms_best_integrated     94.54     96.16     transposed    PowerTransformer       svc_linear
 reads_kingdoms_zip_integrated     91.55     93.15     transposed    PowerTransformer       svc_linear
reads_kingdoms_zinb_integrated     90.91     92.05       original           LogAndPca         mlpc_200
reads_kingdoms_zinb_integrated     90.58     91.50       original           LogAndPca randomForest1200
 reads_kingdoms_zip_integrated     89.02     90.95     transposed QuantileTransformer       svc_linear
   reads_kingdoms_p_integrated     64.69     69.86       original    PowerTransformer         mlpc_200
   reads_kingdoms_p_integrated     64.59     69.58       original    PowerTransformer       svc_linear
```


## reads_
```
                Source  F1-score  Accuracy Pre-preprocess          Preprocess        Algorithm
reads__best_integrated     95.79     96.43     transposed    PowerTransformer       svc_linear
  reads__nb_integrated     95.37     95.89     transposed    PowerTransformer         mlpc_200
reads__best_integrated     95.30     95.61     transposed QuantileTransformer       svc_linear
  reads__nb_integrated     95.29     96.16       original           LogAndPca       svc_linear
 reads__zip_integrated     92.01     93.15     transposed    PowerTransformer       svc_linear
reads__zinb_integrated     90.46     92.32     transposed    PowerTransformer       svc_linear
 reads__zip_integrated     88.48     89.86     transposed    PowerTransformer         mlpc_200
reads__zinb_integrated     88.24     92.32       original           LogAndPca         mlpc_200
   reads__p_integrated     64.17     68.76       original    PowerTransformer         mlpc_200
   reads__p_integrated     63.07     65.20     transposed    PowerTransformer randomForest_500
```


## readsAB_count
```
               Source  F1-score  Accuracy Pre-preprocess          Preprocess        Algorithm
 readsAB_count__Genus     90.23     91.78     transposed    PowerTransformer       svc_linear
readsAB_count__Family     89.92     92.32       original           LogAndPca         mlpc_200
 readsAB_count__Genus     89.11     89.86     transposed QuantileTransformer       svc_linear
readsAB_count__Family     86.73     89.04     transposed    PowerTransformer       svc_linear
 readsAB_count__Order     82.78     85.47     transposed    PowerTransformer         mlpc_200
 readsAB_count__Order     82.73     85.75       original           LogAndPca         mlpc_200
 readsAB_count__Class     76.96     79.72     transposed    PowerTransformer randomForest1200
 readsAB_count__Class     76.49     81.36       original           LogAndPca       svc_linear
readsAB_count__Phylum     65.33     69.86     transposed    PowerTransformer randomForest_500
readsAB_count__Phylum     65.29     70.95     transposed    PowerTransformer randomForest1200
```


## assembly__zip
```
                          Source  F1-score  Accuracy Pre-preprocess       Preprocess  Algorithm
assembly__zip_integrated_reduced     78.69     83.28     transposed PowerTransformer svc_linear
assembly__zip_integrated_reduced     77.98     82.19       original PowerTransformer   mlpc_200
```


## reads_kingdoms_zinb
```
                                Source  F1-score  Accuracy Pre-preprocess       Preprocess  Algorithm
reads_kingdoms_zinb_integrated_reduced     90.79     92.05       original        LogAndPca svc_linear
reads_kingdoms_zinb_integrated_reduced     89.88     91.78     transposed PowerTransformer svc_linear
```


## reads__nb
```
                      Source  F1-score  Accuracy Pre-preprocess          Preprocess  Algorithm
reads__nb_integrated_reduced     95.62     96.43     transposed QuantileTransformer svc_linear
reads__nb_integrated_reduced     94.29     95.34     transposed    PowerTransformer svc_linear
```


##
```
Source  F1-score  Accuracy Pre-preprocess       Preprocess        Algorithm
  lvl4     79.88     83.23     transposed PowerTransformer       svc_linear
  lvl4     77.62     81.30     transposed PowerTransformer         mlpc_200
  lvl3     72.86     77.19     transposed PowerTransformer       svc_linear
  lvl3     71.42     74.46       original        LogAndPca         mlpc_200
  lvl2     63.91     67.59       original        LogAndPca         mlpc_200
  lvl2     61.93     65.94       original        LogAndPca       svc_linear
  lvl1     36.16     41.49       original        LogAndPca randomForest_500
  lvl1     35.50     40.94       original        LogAndPca randomForest1200
```


## reads_count
```
             Source  F1-score  Accuracy Pre-preprocess          Preprocess        Algorithm
 reads_count__Genus     88.78     90.13       original           LogAndPca randomForest_500
reads_count__Family     88.68     90.68       original           LogAndPca randomForest1200
 reads_count__Genus     88.31     91.50       original           LogAndPca         mlpc_200
reads_count__Family     87.83     89.58       original           LogAndPca randomForest_500
 reads_count__Order     83.00     85.20     transposed QuantileTransformer randomForest_500
 reads_count__Order     82.55     87.12       original           LogAndPca         mlpc_200
 reads_count__Class     74.41     80.54       original           LogAndPca       svc_linear
 reads_count__Class     74.05     80.00     transposed    PowerTransformer randomForest1200
reads_count__Phylum     69.89     74.52     transposed    PowerTransformer randomForest1200
reads_count__Phylum     68.70     73.42     transposed    PowerTransformer randomForest_500
```


## assembly_kingdoms_zinb
```
                                   Source  F1-score  Accuracy Pre-preprocess Preprocess  Algorithm
assembly_kingdoms_zinb_integrated_reduced     85.20     87.39       original  LogAndPca   mlpc_200
assembly_kingdoms_zinb_integrated_reduced     83.32     86.57       original  LogAndPca svc_linear
```


## assembly__nb
```
                         Source  F1-score  Accuracy Pre-preprocess       Preprocess  Algorithm
assembly__nb_integrated_reduced     81.92     85.47       original        LogAndPca   mlpc_200
assembly__nb_integrated_reduced     80.58     85.47     transposed PowerTransformer svc_linear
```


## reads__zinb
```
                        Source  F1-score  Accuracy Pre-preprocess       Preprocess  Algorithm
reads__zinb_integrated_reduced     90.74     92.05     transposed PowerTransformer svc_linear
reads__zinb_integrated_reduced     89.17     92.32       original        LogAndPca   mlpc_200
```


## reads__p
```
                     Source  F1-score  Accuracy Pre-preprocess       Preprocess  Algorithm
reads__p_integrated_reduced     65.83     70.68       original PowerTransformer   mlpc_200
reads__p_integrated_reduced     63.36     67.39       original        LogAndPca svc_linear
```


## assembly__p
```
                        Source  F1-score  Accuracy Pre-preprocess          Preprocess  Algorithm
assembly__p_integrated_reduced     65.65     70.68       original QuantileTransformer   mlpc_200
assembly__p_integrated_reduced     62.26     67.67       original    PowerTransformer svc_linear
```


## reads_kingdoms_p
```
                             Source  F1-score  Accuracy Pre-preprocess       Preprocess  Algorithm
reads_kingdoms_p_integrated_reduced     67.57     73.69       original PowerTransformer   mlpc_200
reads_kingdoms_p_integrated_reduced     66.29     70.41       original PowerTransformer svc_linear
```


## reads_kingdoms_best
```
                                Source  F1-score  Accuracy Pre-preprocess       Preprocess  Algorithm
reads_kingdoms_best_integrated_reduced     94.89     96.43     transposed PowerTransformer svc_linear
reads_kingdoms_best_integrated_reduced     94.73     95.89     transposed PowerTransformer   mlpc_200
```


## assembly__zinb
```
                           Source  F1-score  Accuracy Pre-preprocess       Preprocess  Algorithm
assembly__zinb_integrated_reduced     81.99     85.47       original        LogAndPca svc_linear
assembly__zinb_integrated_reduced     80.76     84.93     transposed PowerTransformer svc_linear
```


## assembly_kingdoms
```
                           Source  F1-score  Accuracy Pre-preprocess          Preprocess        Algorithm
assembly_kingdoms_zinb_integrated     84.26     88.21     transposed    PowerTransformer       svc_linear
assembly_kingdoms_best_integrated     83.80     87.12     transposed    PowerTransformer       svc_linear
assembly_kingdoms_zinb_integrated     83.67     85.75       original           LogAndPca         mlpc_200
  assembly_kingdoms_nb_integrated     82.57     86.30     transposed    PowerTransformer         mlpc_200
  assembly_kingdoms_nb_integrated     82.02     84.93     transposed QuantileTransformer randomForest_500
assembly_kingdoms_best_integrated     81.49     85.20       original           LogAndPca       svc_linear
 assembly_kingdoms_zip_integrated     80.06     84.38     transposed    PowerTransformer       svc_linear
 assembly_kingdoms_zip_integrated     79.59     83.56       original           LogAndPca         mlpc_200
   assembly_kingdoms_p_integrated     60.69     66.84       original    PowerTransformer         mlpc_200
   assembly_kingdoms_p_integrated     60.31     65.75     transposed    PowerTransformer         mlpc_200
```


## assembly__best
```
                           Source  F1-score  Accuracy Pre-preprocess       Preprocess  Algorithm
assembly__best_integrated_reduced     82.01     86.30       original        LogAndPca   mlpc_200
assembly__best_integrated_reduced     80.66     85.47     transposed PowerTransformer svc_linear
```


## reads__best
```
                        Source  F1-score  Accuracy Pre-preprocess          Preprocess  Algorithm
reads__best_integrated_reduced     95.48     96.43     transposed    PowerTransformer svc_linear
reads__best_integrated_reduced     94.36     95.06     transposed QuantileTransformer svc_linear
```


## assembly_kingdoms_zip
```
                                  Source  F1-score  Accuracy Pre-preprocess       Preprocess  Algorithm
assembly_kingdoms_zip_integrated_reduced     79.35     84.10     transposed PowerTransformer svc_linear
assembly_kingdoms_zip_integrated_reduced     78.75     83.28       original        LogAndPca   mlpc_200
```


## reads_kingdoms_nb
```
                              Source  F1-score  Accuracy Pre-preprocess       Preprocess  Algorithm
reads_kingdoms_nb_integrated_reduced     96.47     97.26     transposed PowerTransformer svc_linear
reads_kingdoms_nb_integrated_reduced     95.75     96.71     transposed PowerTransformer   mlpc_200
```


## reads__zip
```
                       Source  F1-score  Accuracy Pre-preprocess       Preprocess  Algorithm
reads__zip_integrated_reduced     90.92     93.15     transposed PowerTransformer svc_linear
reads__zip_integrated_reduced     89.38     91.23       original PowerTransformer svc_linear
```


## reads_kingdoms_zip
```
                               Source  F1-score  Accuracy Pre-preprocess       Preprocess  Algorithm
reads_kingdoms_zip_integrated_reduced     92.84     93.69     transposed PowerTransformer svc_linear
reads_kingdoms_zip_integrated_reduced     90.12     91.50     transposed PowerTransformer   mlpc_200
```


## assembly_kingdoms_best
```
                                   Source  F1-score  Accuracy Pre-preprocess       Preprocess  Algorithm
assembly_kingdoms_best_integrated_reduced     82.79     86.02     transposed PowerTransformer   mlpc_200
assembly_kingdoms_best_integrated_reduced     82.16     84.93       original        LogAndPca svc_linear
```


## All groups together
```
                                Source  F1-score  Accuracy Pre-preprocess          Preprocess  Algorithm
  reads_kingdoms_nb_integrated_reduced     96.47     97.26     transposed    PowerTransformer svc_linear
                reads__best_integrated     95.79     96.43     transposed    PowerTransformer svc_linear
  reads_kingdoms_nb_integrated_reduced     95.75     96.71     transposed    PowerTransformer   mlpc_200
          reads__nb_integrated_reduced     95.62     96.43     transposed QuantileTransformer svc_linear
          reads_kingdoms_nb_integrated     95.51     96.16     transposed    PowerTransformer   mlpc_200
          reads_kingdoms_nb_integrated     95.50     96.43     transposed    PowerTransformer svc_linear
        reads__best_integrated_reduced     95.48     96.43     transposed    PowerTransformer svc_linear
                  reads__nb_integrated     95.37     95.89     transposed    PowerTransformer   mlpc_200
                reads__best_integrated     95.30     95.61     transposed QuantileTransformer svc_linear
                  reads__nb_integrated     95.29     96.16       original           LogAndPca svc_linear
        reads_kingdoms_best_integrated     95.12     95.89     transposed QuantileTransformer svc_linear
reads_kingdoms_best_integrated_reduced     94.89     96.43     transposed    PowerTransformer svc_linear
reads_kingdoms_best_integrated_reduced     94.73     95.89     transposed    PowerTransformer   mlpc_200
        reads_kingdoms_best_integrated     94.54     96.16     transposed    PowerTransformer svc_linear
        reads__best_integrated_reduced     94.36     95.06     transposed QuantileTransformer svc_linear
          reads__nb_integrated_reduced     94.29     95.34     transposed    PowerTransformer svc_linear
 reads_kingdoms_zip_integrated_reduced     92.84     93.69     transposed    PowerTransformer svc_linear
                 reads__zip_integrated     92.01     93.15     transposed    PowerTransformer svc_linear
         reads_kingdoms_zip_integrated     91.55     93.15     transposed    PowerTransformer svc_linear
         reads__zip_integrated_reduced     90.92     93.15     transposed    PowerTransformer svc_linear
