# [Pruebas de hipótesis](https://docs.google.com/document/d/1ZTINZnqSaR87t-sDFoLGSnZTBJ8q7hYOjbY2FF-_8ig/edit?usp=sharing)

### 2023-06-03
- Se determinaron objetivos pretendidos en materia de prueba de hipótesis, y cómo encaja el tema con la convocatoria general Camda. Se concluyó que sí constituye materia de interés el determinar si la abundancia tiene asociación con variables ambientales.
- Se revisaron datos disponibles.
- Se habló de regresión en general como metodología para explorar relaciones entre variables, incluyendo pruebas de hipótesis formales. Se distinguió la diferencia entre plantear un objetivo de predicción o clasificación con un objetivo de exploración asociativa entre variables.
- Se contempló la idea de incorporar covariables climáticas por su posible relación con la biodiversidad, y se describió la base de datos bioclim de worldclim.org.
- Se comentaron generalidades de regresión lineal y regresión de Dirichlet. Lo segundo, a la luz de que se visualiza que una descripción más detallada de una muestra será el conjunto de proporciones asociadas a un subconjunto de OTUs comunes a todas las ciudades.

### 2023-06-04
- Se trabajó sobre representación gráficas de datos, con diversidades ecológicas a diferentes niveles taxonómicos.
- Se acordó incorporar metadatos no sólo para el tema climático, sino también para conceptos socio-demográficos. Se compilaron dos: población total de la ciudad, y densidad poblacional.
- Se creó el script de regresión lineal y se revisó la interpretación de las salidas producidas por la función “lm” de R.
- Se corrieron versiones iniciales de los modelos de regresión lineal para todos los índices alfa junto con los metadatos.
- En discusión plenaria se determinó que las variables climáticas al nivel resumen anual posiblemente no sean buenas indicadoras debido a la velocidad con la que se pueden modificar poblaciones biológicas en cuestión. Se determinó entonces enfocarse a variables climáticas con resolución mes de junio de cada año de muestreo.
- Se agregaron muestras adicionales a la base de datos y se hicieron correcciones.
- Se hizo análisis de correlación entre seis posibles índices de biodiversidad para entender la idiosincrasia de cada una de ellas.

### 2023-06-05
- Revision de resultados de la regresión lineal con todos los indices alfa.
- Seleccion de indices Chao1 y Shannon como los más relevantes
- Revisión base de datos de resistencias

### 2023-06-06
- Se discutió regresión Dirichlet para datos composicionales y la diferencia entre dos tipos de parametrizaciones, la común  y la alternativa. Se determinó que la alternativa es mejor para fines de interpretar parámetros estimados en el modelo de regresión.
- Se determinaron phylum para producir datos composicionales con tres o cuatro componentes.
- Se corrieron algunas versiones preliminares de modelos de Dirichlet y se realizaron algunas interpretaciones respecto a la naturaleza de covariables participantes.
- Se representaron en gráficas ternarias datos composicionales crudos y medias estimadas por modelo de regresión Dirichlet.


## [Presentación](https://docs.google.com/presentation/d/1-qJd4-2TZXH2kP6S08iNl8AY2kt0TlMMJKaS4yzM0XM/edit?usp=sharing)

## trabajos faltantes
Visualización de abundancias por ciudad, y a diferentes niveles taxonomicos.
