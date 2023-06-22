'''
Entrada:    Tabla de enzimas de Mifaser en /home/2022_15/c23-func/data/02-annotations/03-mifaser/mifaser-table.tsv
Salida:     Archivos .cvs de las enzimas por niveles de acuerdo a su código en /home/2022_15/c23-func/data/02-annotations/03-mifaser/
                level1.csv
                level2.csv
                level3.csv
'''


import pandas as pd
mifaser = pd.read_csv('../data/03-contingencies/02-mifaser/mifaser-table.tsv', sep = '\t', index_col = 0)

mifaser['level1'] = mifaser.index.str.split('.').str.get(0)
mifaser['level2'] = mifaser['level1'] + '.' + mifaser.index.str.split('.').str.get(1)
mifaser['level3'] = mifaser['level2'] +'.' + mifaser.index.str.split('.').str.get(2)

level1 = mifaser.drop(['level2', 'level3'], axis = 1).groupby(['level1']).sum().T
level2 = mifaser.drop(['level1', 'level3'], axis = 1).groupby(['level2']).sum().T
level3 = mifaser.drop(['level1', 'level2'], axis = 1).groupby(['level3']).sum().T
level4 = mifaser.drop(['level1', 'level2', 'level3'], axis = 1).T

labs = []
for item in level4.index:
    labs.append(item.split('_')[3])

level1['City'] = labs
level2['City'] = labs
level3['City'] = labs
level4['City'] = labs


level1.to_csv('../data/03-contingencies/02-mifaser/level1.csv')
level2.to_csv('../data/03-contingencies/02-mifaser/level2.csv')
level3.to_csv('../data/03-contingencies/02-mifaser/level3.csv')
level4.to_csv('../data/03-contingencies/02-mifaser/level4.csv')
