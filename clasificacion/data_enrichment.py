"""
This code is used to enrich the data from the database
 - First, the data is normalized by rows
 - Second, the data is enriched using SMOTE
"""

# Import libraries
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from imblearn.over_sampling import SMOTE
from sklearn.preprocessing import (Binarizer, LabelEncoder, MinMaxScaler,
                                   Normalizer, OneHotEncoder, OrdinalEncoder,
                                   PowerTransformer, QuantileTransformer,
                                   RobustScaler, StandardScaler)
from sklearn.decomposition import PCA
from sklearn.pipeline import make_pipeline


# Custom functions
class LogScaler:
  def __init__(self):
    pass
  def fit(self, X):
    return self
  def transform(self, X):
    return np.log(X+1)
  def fit_transform(self, X):
    return self.fit(X).transform(X)


class LogAndPca:
  def __init__(self):
    self.pca = PCA()
    pass
  def fit(self, X):
    self.pca.fit(np.log(X+1))
    return self
  def transform(self, X):
    return self.pca.transform(np.log(X+1))
  def fit_transform(self, X):
    return self.pca.fit_transform(np.log(X+1))


# Scalers to use
scalers = {
  "MinMaxScaler": MinMaxScaler(),
  "Normalizer": Normalizer(),
  "PowerTransformer": PowerTransformer(),
  "QuantileTransformer": QuantileTransformer(),
  "QuantileTransformer-50": QuantileTransformer(n_quantiles=50),
  "RobustScaler": RobustScaler(),
  "StandardScaler": StandardScaler(),
  "LogScaler": LogScaler(),
  "LogAndPca": LogAndPca(),
}

# Import data
df_1 = pd.read_csv('Hackaton_junio2023/CodigoDanielS/c23/biom_2016.tsv', sep='\t', header=0)
df_2 = pd.read_csv('Hackaton_junio2023/CodigoDanielS/c23/biom_2017.tsv', sep='\t', header=0)

#rename first column 'OTU'->'OTU ID'
df_2.rename(columns={'OTU':'OTU ID'}, inplace=True)

# Merge data
df_i = pd.merge(df_1, df_2, on='OTU ID', how='outer')

# NaN values are replaced by 0
df_i.fillna(0, inplace=True)

# Block to enrich the data -----------------------------------------------------
data_x = np.array(df_i.iloc[:,1:], dtype=float).T
data_y = ["_".join(h.split('_')[-3:-1]) for h in df_i.head() if h.startswith("CAMDA")]

# Prepare the SMOTE algorithm
smote = SMOTE(sampling_strategy='auto', k_neighbors=5, random_state=42)

# Fit and transform the data
data_x, data_y = smote.fit_resample(data_x, data_y)

# Save the data into a dataframe
df_e = df_i.copy().iloc[:,:1]
idx = {k:0 for k in set(data_y)}
for i in range(len(data_y)):
  city = data_y[i]
  idx[city] += 1
  df_e[f"SMOTE_MetaSUB_{city}_{idx[city]:02d}"] = data_x[i]

# -----------------------------------------------------------------------------
def normalize_data(_df,prefix="",norm="MinMaxScaler"):
  # Log the beginning of the process
  print(f"Normalizing '{prefix}' data with '{norm}' scaler")
  # # take a sabple of the data with N columns and N rows
  # N = 10
  # df_i = df_i.iloc[:N,:N]

  # extract data from the database
  data = _df.iloc[:,1:].values
  data = np.array(data, dtype=float)

  # Start the normalization process
  scaler = scalers[norm]
  df_norm = scaler.fit_transform(data.T).T

  # if the scaler is a PCA, then recover only the first 30 components (30 is arbitrary)
  if "Pca" in norm:
    df_norm = df_norm[:30,:]

  # Save into the original dataframe
  df_o = _df.copy()
  df_o = df_o.iloc[:df_norm.shape[0],:]
  df_o.iloc[:,1:] = df_norm

  # enumerate the rows (in 'OTU ID' column) if there are only 30 rows
  if df_o.shape[0] == 30:
    df_o["OTU ID"] = range(30)

  # # Add new rows to the dataframe with the year of the sample (0:2016, 1:2017)
  # new_row = pd.Series([-1]+[0 if "gCSD16" in h else 1 for h in df_o.columns[1:]], index=df_o.columns)
  # df_o = pd.concat( [new_row.to_frame().T, df_o], ignore_index=True)

  # Block of prints manhattan like plot -----------------------------------------
  # heatmap of the data as a meshgrid
  plt.figure(figsize=(16,9))
  plt.pcolormesh(df_norm.T, cmap='viridis')
  plt.colorbar()
  plt.xlabel("Otus/derived data")
  plt.ylabel("Samples")

  # Block to save the data into a file ------------------------------------------
  scaler_name = norm
  df_o.to_csv(f"Hackaton_junio2023/CodigoDanielS/dta_{prefix}_{scaler_name}.tsv", sep='\t', index=False)
  plt.savefig(f"Hackaton_junio2023/CodigoDanielS/dta_{prefix}_{scaler_name}.png")

  # Finish the program -----------------------------------------------------------
  plt.close()


if __name__ == "__main__":
  sc_list = list(scalers.keys())
  for sc in sc_list:
    # normalize input data
    normalize_data(df_i, prefix="original", norm=sc)
    # normalize enrichment data
    normalize_data(df_e, prefix="enriched", norm=sc)
  pass
