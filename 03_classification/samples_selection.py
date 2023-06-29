"""
this code is used to select samples from the dataset
in a pseudo-random way, so that each fold has the same
number of samples from each city/year combination
"""

import random
import sys
from random import sample

import pandas as pd

# constants
FILENAME = "02_variable_selection/selected_variables_results/integrated_tables/reads_kingdoms_nb_integrated_tv.csv"
SELECTION = "02_variable_selection/validation_set/train_val.csv"
ALTERNATIVE = "02_variable_selection/validation_set/fold_selection.csv"
FOLDS, FOLD = 5, 0

# set the seed for reproducibility
random.seed(42)

# fold overwrite
if len(sys.argv) > 1:
  FOLD = int(sys.argv[1])

# open the file and retrieve the samples' names
sep = {"csv": ",", "tsv": "\t"}[FILENAME.split('.')[-1]]
df = pd.read_csv(FILENAME, sep=sep, header=0)
samples = [ c for c in df.columns if c.startswith("CAMDA")]

# get the labels for each sample
labels = [ "_".join(s.split("_")[-3:-1]) for s in samples ]
labels = list(set(labels))
labels.sort()

# split the samples by label and sort them randomly
samples_by_label = { l: [ s for s in samples if l in s ] for l in labels }
samples_by_label = { l: sample(samples_by_label[l], len(samples_by_label[l])) for l in samples_by_label }
sequential_samples = [ s for l in samples_by_label for s in samples_by_label[l] ]

# assign the samples to each fold
samples_list = [ s for l in samples_by_label for s in samples_by_label[l] ]
samples_by_fold = { i:[] for i in range(FOLDS) }
for i in range(len(samples_list)):
  samples_by_fold[i%FOLDS].append(samples_list[i])

# prepare the train and validation sets
train = [ s for f in samples_by_fold if f!=FOLD for s in samples_by_fold[f] ]
val = samples_by_fold[FOLD]

# prepare the dataframe -------------------------------------------------------
df = pd.DataFrame(columns=["Nom_Col"])
# insert "ID" row
df.loc[0,"Nom_Col"] = "ID"
# insert all the samples sorted alphabetically
sf = { s:("_".join(s.split("_")[:-1]), int(s.split("_")[-1])) for s in samples }
for s in sorted(samples, key=lambda x: sf[x]):
  df.loc[len(df),"Nom_Col"] = s
# set "Train" to one if "Nom_Col" is in the train set
df["Train"] = df["Nom_Col"].apply(lambda x: 1 if x in train else 0)
# set "Validation" to one if "Nom_Col" is in the validation set
df["Validation"] = df["Nom_Col"].apply(lambda x: 1 if x in val else 0)
# set ID row to 1 in both columns
df.loc[0,["Train","Validation"]] = 1
# add a column named "Num_Col" with the number of row starting from 1
df["Num_Col"] = range(1,len(df)+1)
# sort columns ("Num_Col", "Nom_Col", "Train", "Validation")
df = df[["Num_Col","Nom_Col","Train","Validation"]]

# save the dataframe
# use quotes to scape the all the text fields but not the numbers
sep = {"csv": ",", "tsv": "\t"}[SELECTION.split('.')[-1]]
df.to_csv(SELECTION, sep=sep, index=False, header=True, quoting=2)

# prepate alternative dataframe -----------------------------------------------
df = pd.DataFrame(columns=["sample"])
# insert all the samples sorted alphabetically
sf = { s:("_".join(s.split("_")[:-1]), int(s.split("_")[-1])) for s in samples }
for s in sorted(samples, key=lambda x: sf[x]):
  df.loc[len(df),"sample"] = s
# set "fold" to the fold number
sf = { s:i for i in samples_by_fold for s in samples_by_fold[i] }
df["fold"] = df["sample"].apply(lambda x: sf[x])
# change column order
df = df[["fold","sample"]]
# save the dataframe
sep = {"csv": ",", "tsv": "\t"}[SELECTION.split('.')[-1]]
df.to_csv(ALTERNATIVE, sep=sep, index=False, header=True, quoting=2)

# final summary ---------------------------------------------------------------
print(df.head())
print("Number of samples:", len(samples))
print("Number of labels:", len(labels))
print("Number of samples by label:", { l:len(samples_by_label[l]) for l in samples_by_label })
print("Number of samples by fold:", { f:len(samples_by_fold[f]) for f in samples_by_fold })
print("Number of samples in train set:", len(train))
print("Number of samples in validation set:", len(val))

pass