"""
This code is to run the complete pipeline for classification
taking into account the preselection of training and validation data
proposed by the variable selection team
"""

import os
import sys

import matplotlib.pyplot as plt
import pandas as pd
from sklearn.preprocessing import PowerTransformer
from sklearn.neural_network import MLPClassifier
from sklearn.metrics import accuracy_score, balanced_accuracy_score, f1_score, precision_score, recall_score, roc_auc_score, confusion_matrix

# constants
FILENAME = "02_variable_selection/selected_variables_results/integrated_tables/reads_kingdoms_nb_integrated_tv.csv"
SELECTION = "02_variable_selection/validation_set/train_val.csv"

# check if the environment variable is set to plot
ENV_PLOT = os.environ.get('PLOT', False)

# data loading
sep = {"csv": ",", "tsv": "\t"}[FILENAME.split('.')[-1]]
df = pd.read_csv(FILENAME, sep=sep, header=0)

# data preconditioning ---------------------------------------------------------
# get all the cells from second column to the last column
# and all the rows from the fist row to the last row
data = df.iloc[:, 1:].values
# data normalization ( without transposition sklearn makes normalization by column)
data = PowerTransformer().fit_transform(data)
# save the normalized data into the dataframe
df.iloc[:, 1:] = data

# plot data as a heatmap 
if ENV_PLOT:
  # heatmap
  plt.matshow(data.T)
  # get the row names
  rows = [ c for c in df.columns if c.startswith("CAMDA")]
  rows = [ "_".join(c.split("_")[-3:-1]) for c in rows ]
  rows = [ (i,c) for i,c in enumerate(rows) ]
  # for each repeated c keep only the first one
  rows = [ (i,c) for i,c in rows if c not in [c2 for i2,c2 in rows[:i] if c2==c] ]
  plt.yticks(*zip(*rows))
  #plt.show()

# data selection ----------------------------------------------------------------
# read the preselected data list
sep = {"csv": ",", "tsv": "\t"}[SELECTION.split('.')[-1]]
df_sel = pd.read_csv(SELECTION, sep=sep, header=0)
# get the Nom_Col if Train/Validation is 1
cols = [ c for c in df.columns if c.startswith("CAMDA")]
train_samples = df_sel.loc[df_sel["Train"]==1, "Nom_Col"].values
train_samples = [ s for s in train_samples if s in cols]
val_samples = df_sel.loc[df_sel["Validation"]==1, "Nom_Col"].values
val_samples = [ s for s in val_samples if s in cols]
# get the data for the selected samples
train_X = df.loc[:, train_samples].values.T
train_y = [ t.split("_")[-2] for t in train_samples ]
val_X = df.loc[:, val_samples].values.T
val_y = [ t.split("_")[-2] for t in val_samples ]

# data classification -----------------------------------------------------------
# prepare the classifier
clasif = MLPClassifier(hidden_layer_sizes=(200,),max_iter=1000, random_state=42)
clasif.fit(train_X, train_y)
# predict the validation data
pred_y = clasif.predict(val_X)
# print the results
print("Validation results:")
print("  - Number of training samples: {}".format(len(train_y)))
print("  - Number of validation samples: {}".format(len(val_y)))
print("    - Ratio of training samples: {}".format(len(train_y)/(len(val_y)+len(train_y))))
print("    - Number of correct predictions: {}".format(sum([1 for i in range(len(val_y)) if val_y[i]==pred_y[i]])))
print("    - Number of incorrect predictions: {}".format(sum([1 for i in range(len(val_y)) if val_y[i]!=pred_y[i]])))
print("  - Accuracy: {}".format(accuracy_score(val_y, pred_y)))
print("  - Balanced accuracy: {}".format(balanced_accuracy_score(val_y, pred_y)))
print("  - F1 score: {}".format(f1_score(val_y, pred_y, average='weighted')))


pass
