
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

# Resultados

## reads/all

        reads_count__Phylum
                source  score  accuracy prepreprocess        preprocess         algorithm
1  reads_count__Phylum  69.89     74.52    transposed  PowerTransformer  randomForest1200
0  reads_count__Phylum  68.70     73.42    transposed  PowerTransformer  randomForest_500
