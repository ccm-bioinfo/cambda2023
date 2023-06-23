
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

```
	assembly_
                      source  score  accuracy prepreprocess           preprocess         algorithm
1  assembly__best_integrated  84.41     87.67      original            LogAndPca          mlpc_200
0  assembly__best_integrated  83.28     86.84    transposed     PowerTransformer        svc_linear
5    assembly__nb_integrated  82.71     86.30    transposed     PowerTransformer        svc_linear
7  assembly__zinb_integrated  81.10     84.93      original            LogAndPca          mlpc_200
4    assembly__nb_integrated  80.63     85.20      original            LogAndPca          mlpc_200
6  assembly__zinb_integrated  80.33     84.65    transposed  QuantileTransformer  randomForest_500
9   assembly__zip_integrated  77.56     82.19      original     PowerTransformer          mlpc_200
8   assembly__zip_integrated  77.42     82.19      original            LogAndPca          mlpc_200
3     assembly__p_integrated  64.70     70.13    transposed     PowerTransformer  randomForest1200
2     assembly__p_integrated  64.50     70.13    transposed     PowerTransformer  randomForest_500
```
```
	reads_kingdoms
                           source  score  accuracy prepreprocess           preprocess         algorithm
5    reads_kingdoms_nb_integrated  95.51     96.16    transposed     PowerTransformer          mlpc_200
4    reads_kingdoms_nb_integrated  95.50     96.43    transposed     PowerTransformer        svc_linear
9  reads_kingdoms_best_integrated  95.12     95.89    transposed  QuantileTransformer        svc_linear
8  reads_kingdoms_best_integrated  94.54     96.16    transposed     PowerTransformer        svc_linear
1   reads_kingdoms_zip_integrated  91.55     93.15    transposed     PowerTransformer        svc_linear
3  reads_kingdoms_zinb_integrated  90.91     92.05      original            LogAndPca          mlpc_200
2  reads_kingdoms_zinb_integrated  90.58     91.50      original            LogAndPca  randomForest1200
0   reads_kingdoms_zip_integrated  89.02     90.95    transposed  QuantileTransformer        svc_linear
7     reads_kingdoms_p_integrated  64.69     69.86      original     PowerTransformer          mlpc_200
6     reads_kingdoms_p_integrated  64.59     69.58      original     PowerTransformer        svc_linear
```
```
	reads_
                   source  score  accuracy prepreprocess           preprocess         algorithm
3  reads__best_integrated  95.79     96.43    transposed     PowerTransformer        svc_linear
5    reads__nb_integrated  95.37     95.89    transposed     PowerTransformer          mlpc_200
2  reads__best_integrated  95.30     95.61    transposed  QuantileTransformer        svc_linear
4    reads__nb_integrated  95.29     96.16      original            LogAndPca        svc_linear
9   reads__zip_integrated  92.01     93.15    transposed     PowerTransformer        svc_linear
7  reads__zinb_integrated  90.46     92.32    transposed     PowerTransformer        svc_linear
8   reads__zip_integrated  88.48     89.86    transposed     PowerTransformer          mlpc_200
6  reads__zinb_integrated  88.24     92.32      original            LogAndPca          mlpc_200
1     reads__p_integrated  64.17     68.76      original     PowerTransformer          mlpc_200
0     reads__p_integrated  63.07     65.20    transposed     PowerTransformer  randomForest_500
```
```
  source  score  accuracy prepreprocess        preprocess         algorithm
1   lvl4  79.88     83.23    transposed  PowerTransformer        svc_linear
0   lvl4  77.62     81.30    transposed  PowerTransformer          mlpc_200
5   lvl3  72.86     77.19    transposed  PowerTransformer        svc_linear
4   lvl3  71.42     74.46      original         LogAndPca          mlpc_200
7   lvl2  63.91     67.59      original         LogAndPca          mlpc_200
6   lvl2  61.93     65.94      original         LogAndPca        svc_linear
3   lvl1  36.16     41.49      original         LogAndPca  randomForest_500
2   lvl1  35.50     40.94      original         LogAndPca  randomForest1200
```
```
	reads_count
                source  score  accuracy prepreprocess           preprocess         algorithm
1   reads_count__Genus  88.78     90.13      original            LogAndPca  randomForest_500
7  reads_count__Family  88.68     90.68      original            LogAndPca  randomForest1200
0   reads_count__Genus  88.31     91.50      original            LogAndPca          mlpc_200
6  reads_count__Family  87.83     89.58      original            LogAndPca  randomForest_500
5   reads_count__Order  83.00     85.20    transposed  QuantileTransformer  randomForest_500
4   reads_count__Order  82.55     87.12      original            LogAndPca          mlpc_200
9   reads_count__Class  74.41     80.54      original            LogAndPca        svc_linear
8   reads_count__Class  74.05     80.00    transposed     PowerTransformer  randomForest1200
3  reads_count__Phylum  69.89     74.52    transposed     PowerTransformer  randomForest1200
2  reads_count__Phylum  68.70     73.42    transposed     PowerTransformer  randomForest_500
```
```
	readsAB_count
                  source  score  accuracy prepreprocess        preprocess   algorithm
1  readsAB_count__Family  89.92     92.32      original         LogAndPca    mlpc_200
0  readsAB_count__Family  86.73     89.04    transposed  PowerTransformer  svc_linear
```
```
	assembly_kingdoms
                              source  score  accuracy prepreprocess           preprocess         algorithm
3  assembly_kingdoms_zinb_integrated  84.26     88.21    transposed     PowerTransformer        svc_linear
5  assembly_kingdoms_best_integrated  83.80     87.12    transposed     PowerTransformer        svc_linear
2  assembly_kingdoms_zinb_integrated  83.67     85.75      original            LogAndPca          mlpc_200
7    assembly_kingdoms_nb_integrated  82.57     86.30    transposed     PowerTransformer          mlpc_200
6    assembly_kingdoms_nb_integrated  82.02     84.93    transposed  QuantileTransformer  randomForest_500
4  assembly_kingdoms_best_integrated  81.49     85.20      original            LogAndPca        svc_linear
9   assembly_kingdoms_zip_integrated  80.06     84.38    transposed     PowerTransformer        svc_linear
8   assembly_kingdoms_zip_integrated  79.59     83.56      original            LogAndPca          mlpc_200
1     assembly_kingdoms_p_integrated  60.69     66.84      original     PowerTransformer          mlpc_200
0     assembly_kingdoms_p_integrated  60.31     65.75    transposed     PowerTransformer          mlpc_200
```
```
	All groups
                           source  score  accuracy prepreprocess           preprocess         algorithm
3          reads__best_integrated  95.79     96.43    transposed     PowerTransformer        svc_linear
5    reads_kingdoms_nb_integrated  95.51     96.16    transposed     PowerTransformer          mlpc_200
4    reads_kingdoms_nb_integrated  95.50     96.43    transposed     PowerTransformer        svc_linear
5            reads__nb_integrated  95.37     95.89    transposed     PowerTransformer          mlpc_200
2          reads__best_integrated  95.30     95.61    transposed  QuantileTransformer        svc_linear
4            reads__nb_integrated  95.29     96.16      original            LogAndPca        svc_linear
9  reads_kingdoms_best_integrated  95.12     95.89    transposed  QuantileTransformer        svc_linear
8  reads_kingdoms_best_integrated  94.54     96.16    transposed     PowerTransformer        svc_linear
9           reads__zip_integrated  92.01     93.15    transposed     PowerTransformer        svc_linear
1   reads_kingdoms_zip_integrated  91.55     93.15    transposed     PowerTransformer        svc_linear
3  reads_kingdoms_zinb_integrated  90.91     92.05      original            LogAndPca          mlpc_200
2  reads_kingdoms_zinb_integrated  90.58     91.50      original            LogAndPca  randomForest1200
7          reads__zinb_integrated  90.46     92.32    transposed     PowerTransformer        svc_linear
1           readsAB_count__Family  89.92     92.32      original            LogAndPca          mlpc_200
0   reads_kingdoms_zip_integrated  89.02     90.95    transposed  QuantileTransformer        svc_linear
1              reads_count__Genus  88.78     90.13      original            LogAndPca  randomForest_500
7             reads_count__Family  88.68     90.68      original            LogAndPca  randomForest1200
8           reads__zip_integrated  88.48     89.86    transposed     PowerTransformer          mlpc_200
0              reads_count__Genus  88.31     91.50      original            LogAndPca          mlpc_200
6          reads__zinb_integrated  88.24     92.32      original            LogAndPca          mlpc_200
```
