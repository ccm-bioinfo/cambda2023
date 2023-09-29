"""
This code is to run the complete pipeline for classification
taking into account the preselection of training and validation data
proposed by the variable selection team

The preselection is done by the following steps:
  - First, the train/val data is selected using 03_classification/samples_selection.py
  - Second, the data is selected running 02_variable_selection/codes/nb_with_training.sh
  - Finally, data is stored in reads_kingdoms_nb_integrated_tv.csv (complete path shown below)

The pipeline is the following:
  - First, the data is normalized by columns using PowerTransformer
  - Second, the classifier is trained using MLPClassifier
  - Third, the classifier is evaluated using the validation data

Environment variables:
  - PLOT: if set to True, the plots are shown
"""

import datetime
import os
import sys

import matplotlib.pyplot as plt
import pandas as pd
from sklearn.metrics import (accuracy_score, balanced_accuracy_score,
                             confusion_matrix, f1_score, precision_score,
                             recall_score, roc_auc_score)
from sklearn.neighbors import KNeighborsClassifier
from sklearn.neural_network import MLPClassifier
from sklearn.preprocessing import PowerTransformer
from sklearn.svm import SVC

# constants
FILENAME = "Outputs/Variable-selection/reads_kingdoms_nb_integrated_tv.csv"
SELECTION = "Data/train_val.csv"
IMG_PATH = "Outputs/generated_plots"
SEED = 42

# check if the environment variable is set to plot
ENV_PLOT = os.environ.get('PLOT', False)
ENV_FOLD = os.environ.get('FOLD', "-")
ENV_METHOD = os.environ.get('METHOD', "MLP")
plt.rcParams["figure.figsize"] = (6,6)

# data loading
sep = {"csv": ",", "tsv": "\t"}[FILENAME.split('.')[-1]]
df = pd.read_csv(FILENAME, sep=sep, header=0)

# data preconditioning --------------------------------------------------------
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
  rows = [ f"{r[-3:]}_{r[-6:-4]}" for r in rows ]
  rows = [ (i,c) for i,c in enumerate(rows) ]
  # for each repeated c keep only the first one
  rows = [ (i,c) for i,c in rows if c not in [c2 for i2,c2 in rows[:i] if c2==c] ]
  plt.yticks(*zip(*rows))
  # change left and right margins
  plt.subplots_adjust(left=0, right=1)
  #plt.show()
  # verify the save path exists
  if not os.path.exists(IMG_PATH):
    os.makedirs(IMG_PATH)
  # save the plot
  plt.savefig(os.path.join(IMG_PATH, f"heatmap_fold{ENV_FOLD}_{ENV_METHOD}.png"))

# data selection --------------------------------------------------------------
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

# data classification ---------------------------------------------------------
# prepare the classifier
clasif = {
  "MLP": MLPClassifier(hidden_layer_sizes=(200,),max_iter=1000, random_state=SEED, activation="tanh", solver="adam", batch_size=50),
  "SVC": SVC(kernel="linear", random_state=SEED, probability=True, degree=2),
  "KNN": KNeighborsClassifier(n_jobs=2, n_neighbors=2, weights="distance"),
}
clasif = clasif[ENV_METHOD]
clasif.fit(train_X, train_y)
# predict the validation data
pred_y = clasif.predict(val_X)
# prepare data printing -------------------------------------------------------
def _print(txt):
  print(txt)
  if ENV_PLOT:
    # export the results to a file
    with open(os.path.join(IMG_PATH, f"results_fold{ENV_FOLD}.txt"), "a") as f:
      f.write(txt+"\n")
# print the results -----------------------------------------------------------
_print(f"{ENV_METHOD} at {datetime.datetime.now()}")
_print(f"Validation results (fold {ENV_FOLD}):" if ENV_FOLD!="-" else "Validation results:")
_print("  - Number of training samples: {}".format(len(train_y)))
_print("  - Number of validation samples: {}".format(len(val_y)))
_print("    - Ratio of training samples: {}".format(len(train_y)/(len(val_y)+len(train_y))))
_print("    - Number of correct predictions: {}".format(sum([1 for i in range(len(val_y)) if val_y[i]==pred_y[i]])))
_print("    - Number of incorrect predictions: {}".format(sum([1 for i in range(len(val_y)) if val_y[i]!=pred_y[i]])))
_print("  - Accuracy: {}".format(accuracy_score(val_y, pred_y)))
_print("  - Balanced accuracy: {}".format(balanced_accuracy_score(val_y, pred_y)))
_print("  - F1 score: {}".format(f1_score(val_y, pred_y, average='weighted')))

# confusion matrix ------------------------------------------------------------
if ENV_PLOT:
  cm = confusion_matrix(val_y, pred_y)
  plt.matshow(cm, cmap=plt.cm.Blues)
  plt.colorbar()
  # annotate the confusion matrix
  for i in range(cm.shape[0]):
    for j in range(cm.shape[1]):
      if cm[i,j] > 0:
        plt.text(j, i, cm[i, j], va='center', ha='center')
  # annotate the axes
  plt.ylabel('True label')
  plt.xlabel('Predicted label')
  # Add row and column labels ()
  labels = list(set(val_y))
  labels.sort()
  plt.xticks(range(len(labels)), labels, rotation=90)
  plt.yticks(range(len(labels)), labels)
  #plt.show()
  # verify the save path exists
  if not os.path.exists(IMG_PATH):
    os.makedirs(IMG_PATH)
  # save the plot
  plt.savefig(os.path.join(IMG_PATH, f"confusion_matrix_fold{ENV_FOLD}_{ENV_METHOD}.png"))

pass
