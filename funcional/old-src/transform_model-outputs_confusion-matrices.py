#!/usr/bin/env python3

# Entrada:  Resultados de modelos de clasificación en
#           results/predictions_level[n].tsv.

# Salida:   Matrices de confusión en formato de heatmaps que se guardarán en
#           data/08-model-results/confusion_level[n].png.

# Uso:       ./create_minpath_tables.py

import os
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
import sklearn.metrics as sm

base_dir = Path(os.path.realpath(__file__)).parent.parent
input_dir = base_dir/"results"

for lvl in range(1, 5):

    # Leer archivo y dar formato a las listas de predicciones y verdades
    data = pd.read_csv(
        input_dir/f"predictions_level{lvl}.tsv",
        delimiter="\t", index_col="model",
        usecols=["model", "predictions", "true"]
    )

    # Quitar caracteres de predicciones y verdades, y transformar en listas
    for string in ["'", "[", "]", ","]:
        data["predictions"] = data["predictions"].str.replace(string, "", regex=False)
        data["true"] = data["true"].str.replace(string, "", regex=False)
    data = data.apply(lambda x: x.str.split())

    cities = sorted(set(data.iloc[0]["true"]))

    # Crear una matriz de confusión para cada fila
    matrices = np.array([
        sm.confusion_matrix(
            data.loc[row, "predictions"],
            data.loc[row, "true"],
            labels=cities
        ) for row in data.index
    ])
    vmin, vmax = np.min(matrices), np.max(matrices)

    # Inicializar figura
    f, axs = plt.subplots(2, 2, dpi=200)
    f.suptitle(
        f"Level {lvl} EC-based Classification Confusion Matrices",
        fontsize=18
    )
    f.tight_layout()
    f.set_figheight(11)
    f.set_figwidth(10)
    
    # Crear cada heatmap
    i = 0
    for col in range(2):
        for row in range(2):
            sns.heatmap(
                pd.DataFrame(matrices[i], index=cities, columns=cities),
                cbar=False, ax=axs[col, row], vmin=vmin, vmax=vmax,
                cmap="Blues", annot=True
            )
            axs[col, row].set_title(data.index[i])
            axs[col, row].spines['top'].set_visible(True)
            axs[col, row].spines['right'].set_visible(True)
            axs[col, row].spines['bottom'].set_visible(True)
            axs[col, row].spines['left'].set_visible(True)
            if row == 0: axs[col, row].set(ylabel='Actual')
            if col == 1: axs[col, row].set(xlabel='Predicted')
            i += 1

    # Guardar figura
    f.savefig(
        base_dir/f"data/08-model-results/02-mifaser/confusion_level{lvl}.png",
    )
