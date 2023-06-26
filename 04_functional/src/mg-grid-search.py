import pandas as pd
import seaborn as sns
import numpy as np
import multiprocessing
import matplotlib.pyplot as plt
from math import sqrt
from sklearn.model_selection import train_test_split, GridSearchCV, StratifiedKFold
from sklearn.preprocessing import Normalizer, QuantileTransformer, PowerTransformer
from sklearn.ensemble import ExtraTreesClassifier, RandomForestClassifier, VotingClassifier
from sklearn.svm import SVC
from sklearn.neural_network import MLPClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.model_selection import GridSearchCV
from sklearn.metrics import f1_score, accuracy_score, balanced_accuracy_score, precision_score, recall_score, make_scorer, confusion_matrix



PATH_INPUT = '../data/metagenomic/tables/'
PATH_OUTPUT_METACYC_CUMMULATIVE_SCALED = '../data/metagenomic/models/metacyc/cummulative/scaled/'
PATH_OUTPUT_METACYC_CUMMULATIVE_UNSCALED = '../data/metagenomic/models/metacyc/cummulative/unscaled/'
PATH_OUTPUT_METACYC_NONCUMMULATIVE_SCALED = '../data/metagenomic/models/metacyc/noncummulative/scaled/'
PATH_OUTPUT_METACYC_NONCUMMULATIVE_UNSCALED = '../data/metagenomic/models/metacyc/noncummulative/unscaled/'
PATH_OUTPUT_MIFASER = '../data/metagenomic/models/mifaser/'
PATH_OUTPUT = '../data/metagenomic/models/'
PATH_OUTPUT_IMAGES = '../images/'


def make_score_plots(data_name, names, accuracy, balanced_accuracy, f1):
    bar_width = 0.2

    r1 = np.arange(len(names))
    r2 = [x + bar_width for x in r1]
    r3 = [x + bar_width for x in r2]

    fig, ax = plt.subplots()

    ax.grid(axis='y', zorder = 0)
    ax.bar(r1, accuracy, color='blue', width=bar_width, edgecolor=None, label='Accuracy', zorder = 2)
    ax.bar(r2, balanced_accuracy, color='green', width=bar_width, edgecolor=None, label='Balanced Accuracy', zorder = 2)
    ax.bar(r3, f1, color='orange', width=bar_width, edgecolor=None, label='F1', zorder = 2)

    ax.set_xticks([r + bar_width for r in range(len(names))])
    ax.set_xticklabels(names, fontsize=9)

    ax.set_ylabel('Metric Value')
    ax.set_title(f'Comparison of Evaluation Metrics {data_name}')

    ax.legend(loc='lower center', ncol=3, bbox_to_anchor=(0.5, -0.2))


    plt.ylim([0, 1])
    plt.tight_layout()
    plt.savefig(f'{PATH_OUTPUT_IMAGES}{data_name}_results.png', dpi = 200)

def make_cm_plots(data_name, models, predictions, true_):
    cities = sorted(set(true_))
    for item in zip(models, predictions):
        cm = confusion_matrix(true_, item[1], labels = cities)
        fig, ax = plt.subplots(figsize=(6, 6))

        sns.heatmap(cm, annot=True, cmap="Blues", fmt="d", cbar=False, ax=ax)

        ax.set_xlabel('Predicted labels')
        ax.set_ylabel('True labels')
        ax.set_title(f'Confusion Matrix {item[0]}')
        ax.xaxis.set_ticklabels(cities)
        ax.yaxis.set_ticklabels(cities, rotation=0)

        plt.tight_layout()
        plt.savefig(f'{PATH_OUTPUT_IMAGES}confusion_matrix_{data_name}_{item[0]}.png', dpi = 200)

    

def multi_grid_search(data_name, data, out_dir):
    lab = list(data['City'])
    data.drop('City', axis = 1, inplace = True)
    X_train, X_test, y_train, y_test = train_test_split(data, lab, test_size=0.15, random_state=42, stratify = lab)
    transformer = QuantileTransformer(n_quantiles=int(sqrt(len(data)))).fit(X_train)
    X_train_transformed = transformer.transform(X_train)
    X_test_transformed = transformer.transform(X_test)
    stratified_kfold = StratifiedKFold(n_splits=5, shuffle = True, random_state = 0)

    scoring = {
        'accuracy': 'accuracy',
        'f1': make_scorer(f1_score, average='macro'),
        'balanced_accuracy': make_scorer(balanced_accuracy_score)
    }


    # Random Forest
    parameters1 = {'criterion':['entropy', 'gini'], 'n_estimators':[10, 50, 100, 300, 500, 750, 1200], 'max_depth':[5,10,15,20,30,35,40], 'random_state':[0,1,2,3], 'n_jobs':[1]}
    rf = RandomForestClassifier()
    clf1 = GridSearchCV(rf, parameters1, verbose = 1, cv = stratified_kfold, scoring = scoring, refit = 'f1', n_jobs = 1)

    #SVC
    parameters2 = {'kernel':['linear', 'poly','rbf'], 'degree':[2,3,4,5,6,7,8], 'random_state':[0,1,2,3], 'probability':[True]}
    svc = SVC()
    clf2 = GridSearchCV(svc, parameters2,  verbose = 1, cv = stratified_kfold, scoring = scoring, refit = 'f1', n_jobs = 1)

    #MLP
    parameters3 = {
        'hidden_layer_sizes': [(100,), (200,), (50,50,), (20,20,20,)],
        'activation': ['relu', 'tanh'],
        'batch_size':['auto',50, 100],
        'solver': ['adam', 'sgd'],
        'max_iter':[1000, 3000, 5000],
        'random_state':[0,1,2],
        'early_stopping':[False, True],
        'learning_rate': ['constant','adaptive'],
    }

    mlp = MLPClassifier()
    clf3 = GridSearchCV(mlp, parameters3,  verbose = 1, cv = stratified_kfold, scoring = scoring, refit = 'f1', n_jobs = 1)

    #Extra trees
    parameters4 = {'n_estimators':[10, 50, 100, 300, 500, 750, 1200], 'criterion':['entropy', 'gini'], 'max_depth': [5,10,15,20,30,35,40], 'random_state':[0,1,2,3], 'n_jobs':[1]}
    extra_trees = ExtraTreesClassifier()
    clf4 = GridSearchCV(extra_trees, parameters4,  verbose = 1, cv = stratified_kfold, scoring = scoring, refit = 'f1', n_jobs = 1)

    #KNN
    parameters5 = {'n_neighbors':[2,3,4,5,6,7,8,9,10,11,12,13,14,15], 'weights':['uniform', 'distance'], 'n_jobs':[1]}
    knn = KNeighborsClassifier()
    clf5 = GridSearchCV(knn, parameters5,  verbose = 1, cv = stratified_kfold, scoring = scoring, refit = 'f1', n_jobs = 1)

    clf1.fit(X_train_transformed, y_train)
    clf2.fit(X_train_transformed, y_train)
    clf3.fit(X_train_transformed, y_train)
    clf4.fit(X_train_transformed, y_train)
    clf5.fit(X_train_transformed, y_train)

    pd.DataFrame(clf1.cv_results_).to_csv(f'{out_dir}{data_name}_RF_results.csv')
    pd.DataFrame(clf2.cv_results_).to_csv(f'{out_dir}{data_name}_SVC_results.csv')
    pd.DataFrame(clf3.cv_results_).to_csv(f'{out_dir}{data_name}_MLP_results.csv')
    pd.DataFrame(clf4.cv_results_).to_csv(f'{out_dir}{data_name}_ET_results.csv')
    pd.DataFrame(clf5.cv_results_).to_csv(f'{out_dir}{data_name}_KNN_results.csv')
    pd.DataFrame(zip(['RF', 'SVC', 'MLP', 'ET', 'KNN'], [clf1.best_params_ , clf2.best_params_ , clf3.best_params_ , clf4.best_params_ , clf5.best_params_ ])).to_csv(f'{out_dir}best_params_{data_name}.csv')


    best_model1 = clf1.best_estimator_
    best_model2 = clf2.best_estimator_
    best_model3 = clf3.best_estimator_
    best_model4 = clf4.best_estimator_
    best_model5 = clf5.best_estimator_

    voting_classifier_hard = VotingClassifier(
        estimators=[('RF', best_model1), ('SVC', best_model2), ('MLP', best_model3), ('ET', best_model4), ('KNN', best_model5)],
        voting='hard'
    )

    voting_classifier_soft = VotingClassifier(
        estimators=[('RF', best_model1), ('SVC', best_model2), ('MLP', best_model3), ('ET', best_model4), ('KNN', best_model5)],
        voting='soft'
    )

    voting_classifier_hard.fit(X_train_transformed, y_train)
    voting_classifier_soft.fit(X_train_transformed, y_train)

    pred1 = best_model1.predict(X_test_transformed)
    pred2 = best_model2.predict(X_test_transformed)
    pred3 = best_model3.predict(X_test_transformed)
    pred4 = best_model4.predict(X_test_transformed)
    pred5 = best_model5.predict(X_test_transformed)
    pred6 = voting_classifier_hard.predict(X_test_transformed)
    pred7 = voting_classifier_soft.predict(X_test_transformed)

    names = ['RandomForest', 'SVC', 'MLP', 'ExtraTrees', 'KNN', 'VC(hard)', 'VC(soft)']
    preds = [list(pred1), list(pred2), list(pred3), list(pred4), list(pred5), list(pred6), list(pred7)]
    true_ = [y_test, y_test, y_test, y_test, y_test, y_test, y_test]

    predictions_cm = pd.DataFrame(zip(names, preds, true_), columns = ['model', 'predictions', 'true']).to_csv(f'{out_dir}predictions_{data_name}.tsv', sep = '\t')


    accuracies, balanced, f1s = [], [], []

    for p in preds:
        acc, bal, f1 = accuracy_score(y_test, p), balanced_accuracy_score(y_test, p), f1_score(y_test, p, average="macro")
        accuracies.append(acc)
        balanced.append(bal)
        f1s.append(f1)
    

    make_score_plots(data_name, names, accuracies, balanced, f1s)

    make_cm_plots(data_name, names, preds, y_test)

    transformations = ['Quantile Transformation' for _ in range(len(names))]

    pd.DataFrame(zip(names, transformations, accuracies, balanced, f1s), columns = ['Model', 'Transformation', 'Accuracy', 'Balanced Accuracy', 'F1 Score']).to_csv(f'{out_dir}results_{data_name}.tsv', sep = '\t', index = False)


def main():
    #Mifaser tables
    mifaser1 = pd.read_csv(f'{PATH_INPUT}mifaser/lvl1.tsv', sep = '\t', index_col = 0)
    mifaser2 = pd.read_csv(f'{PATH_INPUT}mifaser/lvl2.tsv', sep = '\t', index_col = 0)
    mifaser3 = pd.read_csv(f'{PATH_INPUT}mifaser/lvl3.tsv', sep = '\t', index_col = 0)
    mifaser4 = pd.read_csv(f'{PATH_INPUT}mifaser/lvl4.tsv', sep = '\t', index_col = 0)

    #Metacyc cummulative scaled tables
    metacyc_cummulative_scaled_1 = pd.read_csv(f'{PATH_INPUT}metacyc/cummulative/scaled/lvl1.tsv', sep = '\t', index_col = 0)
    metacyc_cummulative_scaled_2 = pd.read_csv(f'{PATH_INPUT}metacyc/cummulative/scaled/lvl2.tsv', sep = '\t', index_col = 0)
    metacyc_cummulative_scaled_3 = pd.read_csv(f'{PATH_INPUT}metacyc/cummulative/scaled/lvl3.tsv', sep = '\t', index_col = 0)
    metacyc_cummulative_scaled_4 = pd.read_csv(f'{PATH_INPUT}metacyc/cummulative/scaled/lvl4.tsv', sep = '\t', index_col = 0)
    metacyc_cummulative_scaled_5 = pd.read_csv(f'{PATH_INPUT}metacyc/cummulative/scaled/lvl5.tsv', sep = '\t', index_col = 0)
    metacyc_cummulative_scaled_6 = pd.read_csv(f'{PATH_INPUT}metacyc/cummulative/scaled/lvl6.tsv', sep = '\t', index_col = 0)
    metacyc_cummulative_scaled_7 = pd.read_csv(f'{PATH_INPUT}metacyc/cummulative/scaled/lvl7.tsv', sep = '\t', index_col = 0)
    metacyc_cummulative_scaled_8 = pd.read_csv(f'{PATH_INPUT}metacyc/cummulative/scaled/lvl8.tsv', sep = '\t', index_col = 0)

    #Metacyc cummulative unscaled tables
    metacyc_cummulative_unscaled_1 = pd.read_csv(f'{PATH_INPUT}metacyc/cummulative/unscaled/lvl1.tsv', sep = '\t', index_col = 0)
    metacyc_cummulative_unscaled_2 = pd.read_csv(f'{PATH_INPUT}metacyc/cummulative/unscaled/lvl2.tsv', sep = '\t', index_col = 0)
    metacyc_cummulative_unscaled_3 = pd.read_csv(f'{PATH_INPUT}metacyc/cummulative/unscaled/lvl3.tsv', sep = '\t', index_col = 0)
    metacyc_cummulative_unscaled_4 = pd.read_csv(f'{PATH_INPUT}metacyc/cummulative/unscaled/lvl4.tsv', sep = '\t', index_col = 0)
    metacyc_cummulative_unscaled_5 = pd.read_csv(f'{PATH_INPUT}metacyc/cummulative/unscaled/lvl5.tsv', sep = '\t', index_col = 0)
    metacyc_cummulative_unscaled_6 = pd.read_csv(f'{PATH_INPUT}metacyc/cummulative/unscaled/lvl6.tsv', sep = '\t', index_col = 0)
    metacyc_cummulative_unscaled_7 = pd.read_csv(f'{PATH_INPUT}metacyc/cummulative/unscaled/lvl7.tsv', sep = '\t', index_col = 0)
    metacyc_cummulative_unscaled_8 = pd.read_csv(f'{PATH_INPUT}metacyc/cummulative/unscaled/lvl8.tsv', sep = '\t', index_col = 0)
    
    #Metacyc noncummulative scaled tables
    metacyc_noncummulative_scaled_1 = pd.read_csv(f'{PATH_INPUT}metacyc/noncummulative/scaled/lvl1.tsv', sep = '\t', index_col = 0)
    metacyc_noncummulative_scaled_2 = pd.read_csv(f'{PATH_INPUT}metacyc/noncummulative/scaled/lvl2.tsv', sep = '\t', index_col = 0)
    metacyc_noncummulative_scaled_3 = pd.read_csv(f'{PATH_INPUT}metacyc/noncummulative/scaled/lvl3.tsv', sep = '\t', index_col = 0)
    metacyc_noncummulative_scaled_4 = pd.read_csv(f'{PATH_INPUT}metacyc/noncummulative/scaled/lvl4.tsv', sep = '\t', index_col = 0)
    metacyc_noncummulative_scaled_5 = pd.read_csv(f'{PATH_INPUT}metacyc/noncummulative/scaled/lvl5.tsv', sep = '\t', index_col = 0)
    metacyc_noncummulative_scaled_6 = pd.read_csv(f'{PATH_INPUT}metacyc/noncummulative/scaled/lvl6.tsv', sep = '\t', index_col = 0)
    metacyc_noncummulative_scaled_7 = pd.read_csv(f'{PATH_INPUT}metacyc/noncummulative/scaled/lvl7.tsv', sep = '\t', index_col = 0)
    metacyc_noncummulative_scaled_8 = pd.read_csv(f'{PATH_INPUT}metacyc/noncummulative/scaled/lvl8.tsv', sep = '\t', index_col = 0)
    
    #Metacyc noncummulative unscaled tables
    metacyc_noncummulative_unscaled_1 = pd.read_csv(f'{PATH_INPUT}metacyc/noncummulative/unscaled/lvl1.tsv', sep = '\t', index_col = 0)
    metacyc_noncummulative_unscaled_2 = pd.read_csv(f'{PATH_INPUT}metacyc/noncummulative/unscaled/lvl2.tsv', sep = '\t', index_col = 0)
    metacyc_noncummulative_unscaled_3 = pd.read_csv(f'{PATH_INPUT}metacyc/noncummulative/unscaled/lvl3.tsv', sep = '\t', index_col = 0)
    metacyc_noncummulative_unscaled_4 = pd.read_csv(f'{PATH_INPUT}metacyc/noncummulative/unscaled/lvl4.tsv', sep = '\t', index_col = 0)
    metacyc_noncummulative_unscaled_5 = pd.read_csv(f'{PATH_INPUT}metacyc/noncummulative/unscaled/lvl5.tsv', sep = '\t', index_col = 0)
    metacyc_noncummulative_unscaled_6 = pd.read_csv(f'{PATH_INPUT}metacyc/noncummulative/unscaled/lvl6.tsv', sep = '\t', index_col = 0)
    metacyc_noncummulative_unscaled_7 = pd.read_csv(f'{PATH_INPUT}metacyc/noncummulative/unscaled/lvl7.tsv', sep = '\t', index_col = 0)
    metacyc_noncummulative_unscaled_8 = pd.read_csv(f'{PATH_INPUT}metacyc/noncummulative/unscaled/lvl8.tsv', sep = '\t', index_col = 0)
    
    #Kegg table

    #VFDB table

    #UNIPROT table


    '''Hyperparameter search'''

    pool = multiprocessing.Pool()
    parameters = [
        # ('Mifaser_level_1', mifaser1, PATH_OUTPUT_MIFASER),
        # ('Mifaser_level_2', mifaser2, PATH_OUTPUT_MIFASER),
        # ('Mifaser_level_3', mifaser3, PATH_OUTPUT_MIFASER),
        ('Mifaser_level_4', mifaser4, PATH_OUTPUT_MIFASER),
        ('Metacyc_cummulative_scaled_level_1', metacyc_cummulative_scaled_1, PATH_OUTPUT_METACYC_CUMMULATIVE_SCALED),
        ('Metacyc_cummulative_scaled_level_2', metacyc_cummulative_scaled_2, PATH_OUTPUT_METACYC_CUMMULATIVE_SCALED),
        ('Metacyc_cummulative_scaled_level_3', metacyc_cummulative_scaled_3, PATH_OUTPUT_METACYC_CUMMULATIVE_SCALED),
        ('Metacyc_cummulative_scaled_level_4', metacyc_cummulative_scaled_4, PATH_OUTPUT_METACYC_CUMMULATIVE_SCALED),
        ('Metacyc_cummulative_scaled_level_5', metacyc_cummulative_scaled_5, PATH_OUTPUT_METACYC_CUMMULATIVE_SCALED),
        ('Metacyc_cummulative_scaled_level_6', metacyc_cummulative_scaled_6, PATH_OUTPUT_METACYC_CUMMULATIVE_SCALED),
        ('Metacyc_cummulative_scaled_level_7', metacyc_cummulative_scaled_7, PATH_OUTPUT_METACYC_CUMMULATIVE_SCALED),
        ('Metacyc_cummulative_scaled_level_8', metacyc_cummulative_scaled_8, PATH_OUTPUT_METACYC_CUMMULATIVE_SCALED),
        ('Metacyc_cummulative_unscaled_level_1', metacyc_cummulative_unscaled_1, PATH_OUTPUT_METACYC_CUMMULATIVE_UNSCALED),
        ('Metacyc_cummulative_unscaled_level_2', metacyc_cummulative_unscaled_2, PATH_OUTPUT_METACYC_CUMMULATIVE_UNSCALED),
        ('Metacyc_cummulative_unscaled_level_3', metacyc_cummulative_unscaled_3, PATH_OUTPUT_METACYC_CUMMULATIVE_UNSCALED),
        ('Metacyc_cummulative_unscaled_level_4', metacyc_cummulative_unscaled_4, PATH_OUTPUT_METACYC_CUMMULATIVE_UNSCALED),
        ('Metacyc_cummulative_unscaled_level_5', metacyc_cummulative_unscaled_5, PATH_OUTPUT_METACYC_CUMMULATIVE_UNSCALED),
        ('Metacyc_cummulative_unscaled_level_6', metacyc_cummulative_unscaled_6, PATH_OUTPUT_METACYC_CUMMULATIVE_UNSCALED),
        ('Metacyc_cummulative_unscaled_level_7', metacyc_cummulative_unscaled_7, PATH_OUTPUT_METACYC_CUMMULATIVE_UNSCALED),
        ('Metacyc_cummulative_unscaled_level_8', metacyc_cummulative_unscaled_8, PATH_OUTPUT_METACYC_CUMMULATIVE_UNSCALED),
        ('Metacyc_noncummulative_scaled_level_1', metacyc_noncummulative_scaled_1, PATH_OUTPUT_METACYC_NONCUMMULATIVE_SCALED),
        ('Metacyc_noncummulative_scaled_level_2', metacyc_noncummulative_scaled_2, PATH_OUTPUT_METACYC_NONCUMMULATIVE_SCALED),
        ('Metacyc_noncummulative_scaled_level_3', metacyc_noncummulative_scaled_3, PATH_OUTPUT_METACYC_NONCUMMULATIVE_SCALED),
        ('Metacyc_noncummulative_scaled_level_4', metacyc_noncummulative_scaled_4, PATH_OUTPUT_METACYC_NONCUMMULATIVE_SCALED),
        ('Metacyc_noncummulative_scaled_level_5', metacyc_noncummulative_scaled_5, PATH_OUTPUT_METACYC_NONCUMMULATIVE_SCALED),
        ('Metacyc_noncummulative_scaled_level_6', metacyc_noncummulative_scaled_6, PATH_OUTPUT_METACYC_NONCUMMULATIVE_SCALED),
        ('Metacyc_noncummulative_scaled_level_7', metacyc_noncummulative_scaled_7, PATH_OUTPUT_METACYC_NONCUMMULATIVE_SCALED),
        ('Metacyc_noncummulative_scaled_level_8', metacyc_noncummulative_scaled_8, PATH_OUTPUT_METACYC_NONCUMMULATIVE_SCALED),
        ('Metacyc_noncummulative_unscaled_level_1', metacyc_noncummulative_unscaled_1, PATH_OUTPUT_METACYC_NONCUMMULATIVE_UNSCALED),
        ('Metacyc_noncummulative_unscaled_level_2', metacyc_noncummulative_unscaled_2, PATH_OUTPUT_METACYC_NONCUMMULATIVE_UNSCALED),
        ('Metacyc_noncummulative_unscaled_level_3', metacyc_noncummulative_unscaled_3, PATH_OUTPUT_METACYC_NONCUMMULATIVE_UNSCALED),
        ('Metacyc_noncummulative_unscaled_level_4', metacyc_noncummulative_unscaled_4, PATH_OUTPUT_METACYC_NONCUMMULATIVE_UNSCALED),
        ('Metacyc_noncummulative_unscaled_level_5', metacyc_noncummulative_unscaled_5, PATH_OUTPUT_METACYC_NONCUMMULATIVE_UNSCALED),
        ('Metacyc_noncummulative_unscaled_level_6', metacyc_noncummulative_unscaled_6, PATH_OUTPUT_METACYC_NONCUMMULATIVE_UNSCALED),
        ('Metacyc_noncummulative_unscaled_level_7', metacyc_noncummulative_unscaled_7, PATH_OUTPUT_METACYC_NONCUMMULATIVE_UNSCALED),
        ('Metacyc_noncummulative_unscaled_level_8', metacyc_noncummulative_unscaled_8, PATH_OUTPUT_METACYC_NONCUMMULATIVE_UNSCALED)
    ]

    pool.starmap(multi_grid_search, parameters)
    pool.close()
    pool.join()

    



if __name__ == "__main__":
    main()