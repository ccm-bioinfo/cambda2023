"""
this code is to resume the information generated by the clasification
"""

import os
import sys

import pandas as pd

# some constants
OUTPUT_FOLDER = "clasificacion"

# Create a list of folders in current directory
folders = [f for f in os.listdir(OUTPUT_FOLDER) if os.path.isdir(f"{OUTPUT_FOLDER}/{f}")]

# Keep only folders starting with "generated_imgs-"
folders = [f for f in folders if f.startswith("generated_imgs-")]

# Group the folders by string between "-" and "_"
groups = {}
for f in folders:
  key = "_".join(f.split("-")[1].split("_")[:-1])
  if key not in groups:
    groups[key] = []
  groups[key].append(f)

# if there are parameters, keep only the ones that match
if len(sys.argv)>1:
  samples = ["_".join(s.split("_")[:-1]) for s in sys.argv[1:]]
  print(f"Keeping only the following groups: {samples}")
  groups = {k:groups[k] for k in groups if k in samples}

# iterate over the groups
dfs = []
for key in groups:
  df = pd.DataFrame(columns=["source", "score","accuracy", "prepreprocess", "preprocess", "algorithm"])
  for f in groups[key]:
    # retrieve from the file
    source = f.split("-")[1]
    # list all files starting with the file name imgSC
    files = [ff for ff in os.listdir(f"{OUTPUT_FOLDER}/{f}") if ff.startswith("imgSc")]
    # sort the files alphabetically
    files = sorted(files)
    # iterate over the files
    for ff in files[-2:]:
      # retrieve the score/accuracy between "imgSC" and "_"
      data =  ff.split("_")[0][5:]
      score,accuracy = data.split("Ac")
      score = float(score)/100
      accuracy = float(accuracy)/100
      # retrieve the source
      prepreprocess = ff.split("_")[1]
      # retrieve the preprocess
      preprocess = ff.split("_")[2]
      # retrieve the algorithm
      algorithm = "_".join(ff.split("_")[3:]).split(".")[0]
      # append the row
      data = {"source":source, "score":score, "accuracy":accuracy, "prepreprocess":prepreprocess, "preprocess":preprocess, "algorithm":algorithm}
      df.loc[len(df)] = data
    
  # sort the dataframe by score
  df = df.sort_values(by="score", ascending=False)
  # show the dataframe
  print(f"\n\t{key}")
  print(df)
  # append the dataframe to the list
  dfs.append(df)

if len(sys.argv)==1:
  # All groups together
  df = pd.concat(dfs)
  # sort the dataframe by score
  df = df.sort_values(by="score", ascending=False)
  # keep only the first 10
  df = df.head(10)
  # show the dataframe
  print(f"\n\tAll groups")
  print(df)