#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jun  6 10:52:14 2023

@author: victor
"""

import pandas as pd 
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
import os
from sklearn import metrics
from sklearn.metrics import accuracy_score
from sklearn.ensemble import RandomForestClassifier
from sklearn.feature_selection import RFECV, RFE
from sklearn.model_selection import StratifiedKFold
from sklearn.svm import SVC
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.utils.class_weight import compute_class_weight


'''
Representacion de los datos basado en conteos de genes
'''

from sklearn.feature_extraction.text import TfidfTransformer
from sklearn.decomposition import TruncatedSVD, NMF
import pickle

def get_tfidf(data):
    vectorizer = TfidfTransformer()
    X = vectorizer.fit_transform(data)
    tfidf = X.toarray()
    
    return tfidf

# realiza factorizacion SVD o NMF
def get_factorization(data, n_comp=100, nmf=True):
    if nmf==False:
        fact_model = TruncatedSVD(n_components=n_comp)
        fact_model.fit(data)
    else:
        fact_model = NMF(n_components = n_comp, init=None, max_iter=12000)
        fact_model.fit(data)
    
    return fact_model

def save_pickle_model(model_obj, file_path, model_name):    
    pkl_name = os.path.join(file_path, model_name)
    with open(pkl_name,'wb') as file:
        pickle.dump(model_obj,file)

def load_from_pickle(file_path, model_name):
    pkl_name = os.path.join(file_path, model_name)
    with open(pkl_name,'rb') as file:
        fact_model = pickle.load(file)
    
    return fact_model


'''
Reducción y selección de características.
Se probarán diferentes métodos para seleccionar características relevantes. 
Los criterios de relevancia son diferentes para cada método.
Se usarán todos los datos como entrenamiento.
'''
def get_reduced_df(df, varnames, importances_df):
    var_to_drop = [elem for idx, elem in enumerate(varnames) if elem not in importances_df.index]
    reduced_df = df.drop(var_to_drop, axis=1)
    return reduced_df

# selección de características con random forests
# El criterio para la selección de características, es la reducción del índice de impureza de Gini
def rf_features(X_df, y, num_features = 100, n_trees=500, min_samples_split=3):
    rf = RandomForestClassifier(n_estimators=n_trees, min_samples_split=3, n_jobs=-1, random_state=42)
    rf.fit(X_df,y)
    varnames = X_df.columns.tolist()
    importances = rf.feature_importances_
    indices = np.flip(np.argsort(importances))[:num_features]
    fnames = [varnames[i] for i in indices]
    rf_importances = pd.Series(importances[indices], index=fnames)
    
    return rf_importances
    
    
    
# Recursive feature elimination
# En RFE, las variables "importantes" son las que quedan después de elimnar las "menos importantes". 
# El criterio para eliminar un conjunto de variables en cada recursión, 
# son los pesos del modelo base (estimator). En éste caso, se usa una SVM con un kernel lineal, 
# para mayor facilidad y porque es en éste caso, la solución está definida en el espacio original 
# de las variables. No estoy seguro si RFE sea válido (o cómo se haga) al usar un kernel no lineal. 
# Es necesario checarlo.... También puede usarse algún otro estimator.

def rfe_features(X_df, y, num_features = 100):
    svc = SVC(kernel="linear", C=1)
    #clf = LogisticRegression()
    rfe = RFE(estimator=svc, step=1, n_features_to_select=num_features, verbose=False)
    rfe.fit(X_df, y)
    varnames = X_df.columns.tolist()
    rfe_indices = rfe.get_support(indices=True)
    fnames = [varnames[i] for i in rfe_indices]
    rfe_importances = pd.Series(rfe.ranking_[rfe_indices], index=fnames)
    
    return rfe_importances


def split_stratified_into_train_val_test(X, y, frac_train=0.6, frac_val=0.15, frac_test=0.25, std = True, 
                                         two_subsets=False, random_state=None):
    '''
    Splits a dataset into three subsets (train, val, and test)
    following fractional ratios provided by the user, where each subset is
    stratified by the values in y (that is, each subset has
    the same relative frequency of the values in the column). It performs this
    splitting by running train_test_split() twice.

    Parameters
    ----------
    X : numpy dataframe of covariates
    y : numpy array of responses
    frac_train : float
    frac_val   : float
    frac_test  : float
        The ratios with which the dataframe will be split into train, val, and
        test data. The values should be expressed as float fractions and should
        sum to 1.0.
    random_state : int, None, or RandomStateInstance
        Value to be passed to train_test_split().

    Returns
    -------
    df_train, df_val, df_test :
        Dataframes containing the three splits.
    '''
    
    if round(frac_train + frac_val + frac_test,10) != 1.0:
        raise ValueError('fractions %f, %f, %f do not add up to 1.0' % \
                         (frac_train, frac_val, frac_test))

    # Split original dataframe into temp and test dataframes.
    #x_train, x_temp, y_train, y_temp = train_test_split(X, y, stratify=y, test_size=(1.0 - frac_train), random_state=random_state)
    x_temp, x_test, y_temp, y_test = train_test_split(X, y, stratify=y, test_size=(1.0 - (frac_train+frac_val)), random_state=random_state)
    scaler = None
    if std:
        # standardize train_val (temp) and test data
        scaler = StandardScaler()
        x_temp = scaler.fit_transform(x_temp)
        x_test = scaler.transform(x_test)
        
    # weights for class imbalance (https://scikit-learn.org/stable/modules/generated/sklearn.utils.class_weight.compute_class_weight.html)
    class_w = compute_class_weight('balanced',classes=np.unique(y_temp),y=y_temp)
    # the latter is equivalent to:
    # unique, class_counts = np.unique(y_temp, return_counts=True)
    # class_w = sum(class_counts)/(len(unique)*class_counts)    
    if two_subsets:        
        x_train = x_temp
        y_train = y_temp
        x_val = None
        y_val = None
        #return x_train, y_train, x_test, y_test, class_w, scaler
    else:
        # Split the temp dataframe into train and val dataframes.
        relative_frac_val = frac_val / (frac_train + frac_val)
        x_train, x_val, y_train, y_val = train_test_split(x_temp, y_temp, stratify=y_temp, 
                                                          test_size=relative_frac_val, random_state=random_state)
        #assert len(df_input) == len(df_train) + len(df_val) + len(df_test)
    
    return x_train, y_train, x_val, y_val, x_test, y_test, class_w, scaler
    