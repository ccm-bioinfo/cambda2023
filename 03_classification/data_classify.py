"""
This code is used to classify data by city using 5-folds cross validation
"""

import os
from random import sample
import sys

# Import libraries
import pandas as pd
from matplotlib import pyplot as plt
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, confusion_matrix, f1_score
from sklearn.model_selection import StratifiedKFold
from sklearn.neighbors import KNeighborsClassifier
from sklearn.neural_network import MLPClassifier
from sklearn.svm import SVC

# Load the dataset
VERSION = "original"
SCALER = "LogAndPca"
INPUT_FOLDER = "03_classification/generated_data"
OUTPUT_FOLDER = "03_classification/generated_imgs"

# check if there are input parameters
if len(sys.argv)>1:
  VERSION = sys.argv[1]
if len(sys.argv)>2:
  SCALER = sys.argv[2]
df = pd.read_csv(f"{INPUT_FOLDER}/dta_{VERSION}_{SCALER}.tsv", sep='\t', header=0)

# 5-folds column selection
cols = {c:"_".join(c.split("_")[-3:-1]) for c in df.columns[1:]}
cols = {k:v for k,v in cols.items() if k!="OTU ID"}
cols = {k:[c for c in cols if cols[c]==k] for k in set(cols.values())}
cols = {k:sample(v,len(v)) for k,v in cols.items()}
cols = [c for k in cols for c in cols[k]]
cols = {i:cols[i::5] for i in range(5)}

def cmPlot(cm,f1,acc,ax):
  # sort rows/columns row names alphabetically
  cm = cm.sort_index(axis=0).sort_index(axis=1)

  # plot the confusion matrix
  #fig, ax = plt.subplots(figsize=(10,10))
  ax.matshow(cm, cmap=plt.cm.Blues, alpha=0.3)
  for i in range(cm.shape[0]):
      for j in range(cm.shape[1]):
          ax.text(x=j, y=i, s=cm.iloc[i, j], va='center', ha='center', size='small')

  # set x/y labels
  ax.set_xlabel('Predicted Label')
  if fold==0:
    ax.set_ylabel('True Label')

  # show ticks every 1 unit
  ax.set_xticks(range(len(cm.columns)))
  ax.set_yticks(range(len(cm.index)))

  # set tick labels
  ax.set_xticklabels(list(cm.columns), rotation=90)
  ax.set_yticklabels(list(cm.index))

  # set title
  ax.set_title(f"F1={f1:.2f}, ACC={acc:.2f}")


def id2city(_id,short=False):
  """
  This function is used to convert the id to city
  """
  if short:
    return _id.split("_")[-2]
  else:
    return "_".join(_id.split("_")[-3:-1])


def ids2cities(_ids,short=False):
  return [id2city(_id,short=short) for _id in _ids]


def classify(_df, groups, fold, ax, algo):
  """
  This function is used to classify the data by city using 5-folds cross validation
  """

  # Select the data
  train = [groups[i] for i in groups if i!=fold]
  train = [c for train_fold in train for c in train_fold]
  test = groups[fold]

  # Train the model
  model = algo
  model.fit(_df[train][1:].T, ids2cities(train))

  # Predict the data
  pred = model.predict(_df[test][1:].T)

  # Data class correction
  SHORT = True
  pred = [p.split("_")[-1] if SHORT else p for p in pred]
  real = ids2cities(test,short=SHORT)

  # Confusion matrix
  cm = pd.crosstab(real, pred, rownames=['Actual'], colnames=['Predicted'])

  # fill missing columns with 0
  for city in set(cm.index).difference(cm.columns):
    cm[city] = 0
  # sort rows/columns row names alphabetically
  cm = cm.sort_index(axis=0).sort_index(axis=1)
  
  # F1 score multiclass
  f1 = 0
  for city in cm.index:
    tp = cm.loc[city,city]
    fp = cm.loc[city,:].sum() - tp
    fn = cm.loc[:,city].sum() - tp
    f1 += tp/(tp+0.5*(fp+fn))
  f1 /= len(cm.index)

  # Accuracy
  acc = cm.values.diagonal().sum()/cm.values.sum()

  # plot confusion matrix
  cmPlot(cm, f1, acc, ax=ax)

  return cm, f1, acc


if __name__ == "__main__":
  # Initialize constants
  N = 5
  algo = {
    "randomForest1200": RandomForestClassifier(n_estimators=1200, random_state=42),
    "randomForest_500": RandomForestClassifier(n_estimators=500, random_state=42),
    "knn_1": KNeighborsClassifier(n_neighbors=1),
    "knn_3": KNeighborsClassifier(n_neighbors=3),
    "knn_5": KNeighborsClassifier(n_neighbors=5),
    "svc_rbf": SVC(kernel='rbf', gamma='auto', C=1, random_state=42),
    "svc_linear": SVC(kernel='linear', gamma='auto', C=1, random_state=42),
    "svc_poly": SVC(kernel='poly', gamma='auto', C=1, random_state=42),
    "mlpc_200": MLPClassifier(hidden_layer_sizes=(200,),max_iter=1000, random_state=42),
  }
  results = {}
  for alg in algo:
    # Log the beginning of the classification
    print(f"\tClassification using {alg}")
    # Initialize variables
    c_acc = 0
    c_f1 = 0
    # Prepare plot
    fig, axs = plt.subplots(1, N, figsize=(20,5))
    axs_map = {i:axs[i] for i in range(N)}
    # Run the classification
    for fold in range(N):
      cm, f1, acc = classify(df, cols, fold, axs_map[fold], algo[alg])
      print(f"Fold {fold+1}: F1 score = {f1:.3f}\tAccuracy = {acc:.3f}")
      #print(cm)
      c_acc += acc
      c_f1 += f1
    # Print the average
    print(f"Average: F1 score = {c_f1/N:.3f}\tAccuracy = {c_acc/N:.3f}")
    fig.suptitle(f"{VERSION} - {SCALER} (F1={c_f1/N:.3f}, ACC={c_acc/N:.3f}) - {alg}")
    # check if the output folder exists
    if not os.path.exists(OUTPUT_FOLDER):
      os.makedirs(OUTPUT_FOLDER)
    # Save the plot
    plt.savefig(f"{OUTPUT_FOLDER}/img_{VERSION}_{SCALER}_{alg}.png")
    results[alg] = (c_f1/N, c_acc/N, alg, fig)
    plt.pause(0.1)

  # Sort by F1 score and accuracy as a secondary key
  results = {k:results[k] for k in sorted(results, key=lambda x: (results[x][0],results[x][1]), reverse=True)}
  # save the best 2 models
  for i,alg in enumerate(results):
    if i<2:
      # score as 4 digits integer
      score = int(results[alg][0]*10000)
      score = f"{score:04d}"
      # accuracy as 4 digits integer
      accuracy = int(results[alg][1]*10000)
      accuracy = f"{accuracy:04d}"
      # save the figure
      results[alg][-1].savefig(f"{OUTPUT_FOLDER}/imgSc{score}Ac{accuracy}_{VERSION}_{SCALER}_{alg}.png")
    else:
      break

  #plt.show()
  pass