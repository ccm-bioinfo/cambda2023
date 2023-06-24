import pandas as pd
#table = open('missingAmr_Table.tsv','r')

table = pd.read_table('amr/missingAmr_species_20230606.txt',sep='\t')
out = open('amr/missingAmr.fasta','w')
#0      1       2       3           4           5        6      7           8
#SORT	gene	species	Found in	sequence	VFDB	Class	Subclass	Referencias

for _,row in table.iterrows():
    geneName = row.gene
    sequence = row.sequence
    if pd.isna(sequence) or 'FOUND'.lower() in sequence.lower() or 'INVESTIGAR'.lower() in sequence.lower():
        continue
#    if 'sila' in geneName:
#        dummy=0
    out.write(f'>{geneName}\n')
    lines = sequence.split('\n')
    for i in range(1,len(lines)):
        out.write(lines[i])
    out.write('\n')
    
out.close()