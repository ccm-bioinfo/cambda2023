'''
Entrada:    Tabla de enzimas de Mifaser en /home/2022_15/c23-func/data/02-annotations/03-mifaser/mifaser-table.tsv
Salida:     Archivos .cvs de las enzimas por niveles de acuerdo a su código en /home/2022_15/c23-func/data/02-annotations/03-mifaser/
                level1.csv
                level2.csv
                level3.csv
'''


import pandas as pd
mifaser = pd.read_csv('../data/02-annotations/03-mifaser/mifaser-table.tsv', sep = '\t', index_col = 0)
mifaser = mifaser.T

labs = []
for item in mifaser.index:
    labs.append(item.split('_')[3])

mifaser['City'] = labs

mifaser2 = mifaser.drop('City', axis = 1)


cols1 = [item.split('.')[0] for item in mifaser2.columns]

for level in set(cols1):
    cols_aux = [x for x in mifaser2.columns if x.split('.')[0] == level]
    mifaser[f'{level}'] = mifaser[cols_aux].sum(axis = 1)

mifaser_level_1 = mifaser
mifaser_level_1 = mifaser_level_1.drop(mifaser2.columns, axis = 1)
mifaser_level_1 = mifaser_level_1.drop('City', axis = 1)
mifaser_level_1['City'] = mifaser['City']


cols2 = [item.split('.')[1] for item in mifaser2.columns]
for level in set(cols2):
    cols_aux = [x for x in mifaser2.columns if x.split('.')[1] == level]
    mifaser[f'{level}'] = mifaser[cols_aux].sum(axis = 1)
    
mifaser_level_2 = mifaser
mifaser_level_2 = mifaser_level_2.drop(mifaser2.columns, axis = 1)
mifaser_level_2 = mifaser_level_2.drop('City', axis = 1)
mifaser_level_2['City'] = mifaser['City']

cols3 = [item.split('.')[2] for item in mifaser2.columns]
for level in set(cols3):
    cols_aux = [x for x in mifaser2.columns if x.split('.')[2] == level]
    mifaser[f'{level}'] = mifaser[cols_aux].sum(axis = 1)
    
mifaser_level_3 = mifaser
mifaser_level_3.drop(mifaser2.columns, axis = 1)
mifaser_level_3.drop('City', axis = 1)
mifaser_level_3['City'] = mifaser['City']

mifaser_level_1.to_csv('')
mifaser_level_2
mifaser_level_3