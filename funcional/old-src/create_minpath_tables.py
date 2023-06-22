#!/usr/bin/env python3

# Entrada:  Resultados de categorías funcionales de Minpath Metacyc encontrados
#           en data/02-annotations/04-minpath/01-metagenomes/*

# Salida:   Tablas de contingencias de muestras contra funciones a data/
#           03-contingencies/01-minpath/level[n].tsv

# Uso:       ./create_minpath_tables.py

import os
from pathlib import Path
import pandas as pd

base_dir = Path(os.path.realpath(__file__)).parent.parent
input_dir = base_dir/"data/02-annotations/04-minpath/01-metagenomes"
data_dict = {}

# Para cada nivel de anotación funcional
for lvl in range(1, 9):

    # Leer todos los archivos
    for file in input_dir.glob("*"):

        # Obtener la columna del nivel correspondiente
        base = file.stem
        col = pd.read_csv(file, sep="\t", usecols=[f"Level{lvl}"])[f"Level{lvl}"]

        # Contar cada función y agregar al diccionario
        data_dict[base] = dict(col.value_counts())

    # Generar tabla de contingencia y guardar
    pd.DataFrame(data_dict).fillna(0).to_csv(
        base_dir/f"data/03-contingencies/01-minpath/level{lvl}.tsv", sep="\t"
    )
