card = open('aro_index.tsv','r')
aro = dict()

for line in card:
# sample line
# 0             1           2                   3           4           5           6                   7               8               9           10                      11  
# ARO Accession	CVTERM ID	Model Sequence ID	Model ID	Model Name	ARO Name	Protein Accession	DNA Accession	AMR Gene Family	Drug Class	Resistance Mechanism	CARD Short Name    
# ARO:3007014	45483	8126	5730	qacJ	qacJ	CAD55144.1	AJ512814.1	small multidrug resistance (SMR) antibiotic efflux pump	disinfecting agents and antiseptics	antibiotic efflux	qacJ
    fields = line.split('\t')
    name = fields[5]
    family = fields[8]
    drugClass = fields[9]
    mechanism = fields[10]
    aro[name] = [ family, drugClass, mechanism ]

card.close()

camda = open('amr-biom.tsv','r')
out = open('amr-biom_card_info.tsv','w')
out.write(f'name\tfamily\tdrugClass\tmechanism\t{camda.readline()[1:]}')

for line in camda:
    gene = line.split('\t')[0]
    cardInfo = aro[gene]
    out.write(f'{gene}\t{cardInfo[0]}\t{cardInfo[1]}\t{cardInfo[2]}\t{line[len(gene)+1:]}')

out.close()
