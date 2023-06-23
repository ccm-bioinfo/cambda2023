#!/usr/bin/env python3

from pathlib import Path
import sys
import pandas as pd

data_dict = {}
name_to_aro = {}

for file in sys.argv[1:]:
    base = Path(file).stem
    col = pd.read_csv(file, sep="\t", usecols=["Best_Hit_ARO"])["Best_Hit_ARO"]
    aro = pd.read_csv(file, sep="\t", usecols=["ARO"])["ARO"]
    data_dict[base] = dict(col.value_counts())
    col_to_aro = dict(
        pd.DataFrame(
            {"name": col, "aro": aro}
        ).drop_duplicates().set_index("name")["aro"]
    )
    name_to_aro.update(col_to_aro)

table = pd.DataFrame(data_dict).fillna(0)
aro_col = table.index.to_series().apply(lambda x: name_to_aro[x])
presence = table.astype(bool).astype(int)
table.insert(0, "aro", aro_col)
presence.insert(0, "aro", aro_col)
table.to_csv("amr-counts.tsv", sep="\t")
presence.to_csv("amr-presence.tsv", sep="\t")
