import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn import tree
from sklearn.metrics import f1_score
#from imblearn.over_sampling import SMOTE
#from lazypredict.Supervised import LazyClassifier
from sklearn.preprocessing import Normalizer
from sklearn.preprocessing import QuantileTransformer
from sklearn.preprocessing import PowerTransformer
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import ExtraTreesClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn.svm import SVC
from sklearn.neighbors import KNeighborsClassifier
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.linear_model import Perceptron
from sklearn.neural_network import MLPClassifier
from sklearn.ensemble import BaggingClassifier
#from xgboost import XGBClassifier
from sklearn.model_selection import GridSearchCV
from sklearn.metrics import f1_score
from sklearn.metrics import f1_score, make_scorer
from sklearn.metrics import accuracy_score
from sklearn.metrics import balanced_accuracy_score
from sklearn.metrics import accuracy_score, precision_score, recall_score
from sklearn.model_selection import GridSearchCV, StratifiedKFold

def scores(model, pred, true):
    acc, bal, f1 = accuracy_score(true, pred), balanced_accuracy_score(true, pred), f1_score(true, pred, average="micro")
    print(f'Accuracy: {accuracy_score(true, pred)}')
    print(f'Balanced: {balanced_accuracy_score(true, pred)}')
    print(f'F1: {f1_score(true, pred, average="micro")}')
    pd.DataFrame(zip(['Accuracy', 'Balanced Accuracy', 'F1'], [acc, bal, f1])).to_csv(f'test_results{level}_{model}.csv')

level = 3

# for level in range(1, 3):
data = pd.read_csv(f'../data/02-annotations/03-mifaser/level{level}.csv', index_col = 0)

lab = list(data['City'])
data.drop('City', axis = 1, inplace = True)

stratified_kfold = StratifiedKFold(n_splits=5, shuffle = True, random_state = 0)

'''Hyperparameter search'''

scoring = {
    'accuracy': 'accuracy',
    'precision': 'precision_macro',
    'recall': 'recall_macro',
    'f1': make_scorer(f1_score, average='macro'),
    'balanced_accuracy': make_scorer(balanced_accuracy_score)
}


# Random Forest
parameters1 = {'criterion':['entropy', 'gini'], 'n_estimators':[10, 50, 100, 300, 500, 750, 1200], 'max_depth':[3,5,8,10,12,15,20,30], 'random_state':[0,1,2,3,4,5,6,7], 'n_jobs':[-1]}
rf = RandomForestClassifier()
clf1 = GridSearchCV(rf, parameters1, verbose = 3, cv = stratified_kfold, scoring = scoring, refit = 'f1', n_jobs = -1)

#SVC
parameters2 = {'kernel':['linear', 'poly'], 'degree':[2,3,4,5,6,7,8], 'random_state':[0,1,2,3,4,5,6,7]}
svc = SVC()
clf2 = GridSearchCV(svc, parameters2,  verbose = 3, cv = stratified_kfold, scoring = scoring, refit = 'f1', n_jobs = -1)

#MLP
parameters3 = {
    'hidden_layer_sizes': [(100,), (50,50,), (20,20,20,)],
    'activation': ['relu', 'tanh'],
    'solver': ['adam', 'sgd'],
    'random_state':[0,1,2,3,4,5,6,7],
    'learning_rate': ['constant','adaptive', 'invscaling'],
    'max_fun':[1000, 5000, 10000]
}

mlp = MLPClassifier()
clf3 = GridSearchCV(mlp, parameters3,  verbose = 3, cv = stratified_kfold, scoring = scoring, refit = 'f1', n_jobs = -1)

#Extra trees
parameters4 = {'n_estimators':[10, 50, 100, 300, 500, 750, 1200], 'criterion':['entropy', 'gini'], 'max_depth': [3,5,8,10,12,15,20,30], 'random_state':[0,1,2,3,4,5,7], 'n_jobs':[-1]}
extra_trees = ExtraTreesClassifier()
clf4 = GridSearchCV(extra_trees, parameters4,  verbose = 3, cv = stratified_kfold, scoring = scoring, refit = 'f1', n_jobs = -1)

X_train, X_test, y_train, y_test = train_test_split(data, lab, test_size=0.15, random_state=42, stratify = lab)
transformer = QuantileTransformer().fit(X_train)
X_train_transformed = transformer.transform(X_train)
X_test_transformed = transformer.transform(X_test)

#sm = SMOTE(sampling_strategy = {'AKL':40, 'BER':40, 'BOG':40, 'DEN':40, 'DOH':40, 'ILR':40, 'LIS':40, 'NYC':40, 'SAC':40, 'TOK':40, 'BAL':40, 'MIN':40, 'SAN':40, 'SAO':40, 'VIE':40, 'ZRH':40}, k_neighbors = 3)

#X_res, y_res = sm.fit_resample(X_train_transformed,  y_train)

clf1.fit(X_train_transformed, y_train)
clf2.fit(X_train_transformed, y_train)
clf3.fit(X_train_transformed, y_train)
clf4.fit(X_train_transformed, y_train)


pd.DataFrame(clf1.cv_results_).to_csv(f'RF_results{level}.csv')
pd.DataFrame(clf2.cv_results_).to_csv(f'SVC_results{level}.csv')
pd.DataFrame(clf3.cv_results_).to_csv(f'MLP_results{level}.csv')
pd.DataFrame(clf4.cv_results_).to_csv(f'ET_results{level}.csv')

best_model1 = clf1.best_estimator_
best_model2 = clf2.best_estimator_
best_model3 = clf3.best_estimator_
best_model4 = clf4.best_estimator_

scores('RandomForest', best_model1.predict(X_test_transformed), y_test)
scores('SVC', best_model2.predict(X_test_transformed), y_test)
scores('MLP', best_model3.predict(X_test_transformed), y_test)
scores('ExtraTrees', best_model4.predict(X_test_transformed), y_test)
