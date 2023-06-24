#!/usr/bin/env python3

# Entrada:  Tablas de contingencias de muestras contra funciones en data/
#           03-contingencies/01-minpath/level[n].tsv

# Salida:   Gráficas de PCA en dos dimensiones a data/05-images/01-minpath-pca/
#           level[n].png

# Uso:       ./create_minpath_pca.py

import os
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from pathlib import Path
from sklearn.decomposition import PCA

base_dir = Path(os.path.realpath(__file__)).parent.parent
input_dir = base_dir/"data/03-contingencies/01-minpath"
output_dir = base_dir/"data/05-images/01-minpath-pca"

for lvl in range(1, 9):
    data = pd.read_csv(input_dir/f"level{lvl}.tsv", sep="\t", index_col=0)
    pca = PCA(n_components=2)
    pca.fit_transform(data)
    x, y = pca.components_
    hue = data.columns.str.split("_").str.get(3)

    sns.scatterplot(x=x, y=y, hue=hue, legend=False)

    plt.savefig(output_dir/f"level{lvl}.png")
