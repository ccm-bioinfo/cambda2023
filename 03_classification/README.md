
# Pre-requisitos
- El listado de pre-requisitos de librerías estará guardado dentro del archivo [requirements](https://github.com/nselem/ccm-bioinfomatica-lab/tree/main/Hackaton_junio2023/CodigoDanielS/requirements.txt)
- En cuanto a datos de entrada, el código está preparado para recibir la lísta de otus en las carpetas c23/biom_2016.tsv y c23/biom_2017.tsv

# Flujo de trabajo

![image](aux/workFlow.png)

El flujo de trabajo está pensado dos etapas de procesamiento, la etapa cero integraría los datos iniciales adquiridos desde las tablas de otus.

## data_enrichment.py
La primer etapa de procesamiento se integra con los códigos de normalización de datos, éstos son pre-procesados en dos caminos diferentes.
Normalización empleando algoritmos estandar de scikit-learn, de entre los cuales se usó MinMaxScaler, Normalizer, OneHotEncoder, OrdinalEncoder, PowerTransformer, QuantileTransformer, RobustScaler, StandardScaler.
Normalización basada en log base 10 sumando uno para manejar errores con el logarítmo de cero, esta estrategia se siguió sin y con selección de parámetros mediante PCA.

El código adicionalmente a estas normalizaciones también integra un enriquecimiento de datos usando los códigos de SMOTE, librería para enriquecimiento de datos desbalanceados.
El conjunto de datos enriquecidos finalmente no fue usado en el pipeline final debido a sesgoz de datos que produce ya que el enriquecimiento fue realizado ántes de separar en conjuntos de prueba y validación.

## data_classify.py
La segunda etapa de procesamiento integra los códigos de clasificacion y evaluación de los modelos, éstos códigos están preparados para validar una lista de modelos contra los datos pre-procesados en la búsqueda y comparación de los resultados.

Cada algoritmo elegido dentro de este código fue seleccionado mediante pruebas adicionales realizadas por los miembros del equipo.
Los códigos, salvo el correspondiente al doctor Balanzario, se pueden leer en la carpeta [other_codes](https://github.com/nselem/ccm-bioinfomatica-lab/tree/main/Hackaton_junio2023/CodigoDanielS/other_codes)

## other_codes
Aquí se agrupan todos los códigos de trabajo que se siguieron durante el proceso del hackaton, prácticamente todas las ideas desarrolladas ya están integradas en el código principal.
Para referencia se incluye como código adicional.

## Extras
Adicionalmente se incluye un código relacionado ([data_fetch.py](https://github.com/nselem/ccm-bioinfomatica-lab/tree/main/Hackaton_junio2023/CodigoDanielS/data_fetch.py)) a la adquisición de datos desde ncbi, éste código no se completó por un error y falta de tiempo, sin embargo a partir de aquí se puede extender para automatizar la descarga de datos.

# Results


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


## All groups together
```
                        Source  F1-score  Accuracy Pre-preprocess          Preprocess        Algorithm
        reads__best_integrated     95.79     96.43     transposed    PowerTransformer       svc_linear
  reads_kingdoms_nb_integrated     95.51     96.16     transposed    PowerTransformer         mlpc_200
  reads_kingdoms_nb_integrated     95.50     96.43     transposed    PowerTransformer       svc_linear
          reads__nb_integrated     95.37     95.89     transposed    PowerTransformer         mlpc_200
        reads__best_integrated     95.30     95.61     transposed QuantileTransformer       svc_linear
          reads__nb_integrated     95.29     96.16       original           LogAndPca       svc_linear
reads_kingdoms_best_integrated     95.12     95.89     transposed QuantileTransformer       svc_linear
reads_kingdoms_best_integrated     94.54     96.16     transposed    PowerTransformer       svc_linear
         reads__zip_integrated     92.01     93.15     transposed    PowerTransformer       svc_linear
 reads_kingdoms_zip_integrated     91.55     93.15     transposed    PowerTransformer       svc_linear
reads_kingdoms_zinb_integrated     90.91     92.05       original           LogAndPca         mlpc_200
reads_kingdoms_zinb_integrated     90.58     91.50       original           LogAndPca randomForest1200
        reads__zinb_integrated     90.46     92.32     transposed    PowerTransformer       svc_linear
          readsAB_count__Genus     90.23     91.78     transposed    PowerTransformer       svc_linear
         readsAB_count__Family     89.92     92.32       original           LogAndPca         mlpc_200
          readsAB_count__Genus     89.11     89.86     transposed QuantileTransformer       svc_linear
 reads_kingdoms_zip_integrated     89.02     90.95     transposed QuantileTransformer       svc_linear
            reads_count__Genus     88.78     90.13       original           LogAndPca randomForest_500
           reads_count__Family     88.68     90.68       original           LogAndPca randomForest1200
         reads__zip_integrated     88.48     89.86     transposed    PowerTransformer         mlpc_200
```