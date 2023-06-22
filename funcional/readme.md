
## Model selection
First we performed a stratified k-fold split on the data to get a representative testing set of the 15% of the entire dataset which was assigned to be our testing set.

After that, we used a quantile transformation to avoid the problem of the different ranges on each variable. We fitted the transformation on the trainning set and then applied it to both trainning and testing sets.

Then, we focused on exploring five algorithms to address the problem of the sample classification. Theese algorithms either were the best performing in a fast analysis using LazyPredict library or were included because we wanted to see if it could improve its performance with later enhancing.

The algorithms we considered were:
 - Random Forest
 - Support Vector Classifier
 - Multi-layer perceptron
 - Extremely Randomized Trees
 - K-nearest neighbours

For each of this models we performed a 5-fold cross validation Grid Search for hyperparameter tunning. The hyperparameters tested are described in the tables below.

Random Forest:

| Parameter     | Values                 |
| ------------- | ---------------------- |
| Criterion     | entropy, gini index               |
| Number of estimators | 10, 50, 100, 300, 500, 750, 1200       |
| Max depth  | 3,5,8,10,12,15,20,30,35,40   |
| Random state  | 0,1,2,3,4,5,6,7 |

Support Vector Classifier:

| Parameter     | Values                 |
| ------------- | ---------------------- |
| Kernel     | lineal, polynomial                |
| Degree | 2,3,4,5,6,7,8       |
| Random state  | 0,1,2,3,4,5,6,7 |

Multi-layer perceptron:

| Parameter     | Values                 |
| ------------- | ---------------------- |
| Hidden layer sizes     | (100,), (50,50,), (20,20,20,)                |
| Activation function | relu, tanh, logistic       |
| Batch size | auto, 20, 50, 100       |
| Solver  | adam, sgd |
| Maximun iterations  | 100, 200, 300, 400, 500, 800, 1000, 3000 |
| Random state  | 0,1,2,3,4,5,6,7 |
| Warm start  | True, False |
| Early stopping  | True, False |
| Learning rate  | constant, adaptive, invscaling |


Extremely Randomized Trees:

| Parameter     | Values                 |
| ------------- | ---------------------- |
| Criterion     | Entropy, Gini                |
| Number of estimators | 10, 50, 100, 300, 500, 750, 1200       |
| Max depth  | 3,5,8,10,12,15,20,30,35,40   |
| Random state  | 0,1,2,3,4,5,6,7 |

K-nearest neighbours:

| Parameter     | Values                 |
| ------------- | ---------------------- |
| Number of neighbours     | 2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21               |
| Weights | uniform, distance       |

After selecting the best hyperparameters for the models we evaluated them using three metrics:
    - Accuracy
    - Balanced accuracy
    - F1 Score

We evaluated the predictions made by each of the individual models and an ensemble of the five models using a hard voting strategy and another using a soft voting method.

At the end we compared the performance of the 7 models (5 original models + 2 ensembles) for each of the functional annotations we made. 

Please document your script to functional annotations to make them repeatable.  
We annotated with Kegg, VFDB, Uniprot, MiFase, MetaCyc, and InterproSCAN.
To do:
- All tables are complete
## MiFase (Chihuil-Anton)  👀  
Already included (Results need to be described **Rafa**)
## MetaCyc (Chihuil-Anton)  👀  
Already had been included (Results need to be characterized **Rafa**)
## Kegg, (Huawei-Mirna)  👀  
To be included in models  
## VFDB, (Huawei-Mirna)  👀  
Few results ¿How few?  
## Uniprot (Huawei-Mirna) 👀  
**Karina** obtained Table by city  
## InterproSCAN (Chihuil-Miguel)  👀  
Not finished for all cities  
Interpro.sh -i <inputfile>  

