amrFile = open('amr_counts_class.tsv','r')
out = open('amr_counts_collapsed_count_variants.tsv','w')
headers = amrFile.readline()[:-1].split('\t')

flagCountVariants = True

# header line
# name	ARO	ARO_Trace	Aro_name_trace	family	drugClass	mechanism	class	CAMDA23_MetaSUB_gCSD16_AKL_1	CAMDA23_MetaSUB_gCSD16_AKL_10 ...
# 0     1   2           3               4       5           6           7           8   ...
numSamples = len(headers[8:])
aroClasses = set()

for line in amrFile:
    fields = line[:-1].split('\t')
    aroClass = fields[7]
    aroClasses.add(aroClass)

# rewind and skip header
amrFile.seek(0)
amrFile.readline()

listClasses = list(aroClasses)
classCounts = dict()

# initialize class counts for all samples
for c in listClasses:
    classCounts[c]= list()
    for s in range(numSamples):
        classCounts[c].append(0)

# count classes
for line in amrFile:
# header line
# name	ARO	ARO_Trace	Aro_name_trace	family	drugClass	mechanism	class   CAMDA23_MetaSUB_gCSD16_AKL_1	CAMDA23_MetaSUB_gCSD16_AKL_10 ...
# 0     1   2           3               4       5           6           7       8   ...
    fields = line[:-1].split('\t')
    aroClass = fields[7]
    counts = fields[8:]
    for n,i in zip(counts,range(len(counts))):
        if flagCountVariants:
            if int(n)>0:
                classCounts[aroClass][i] += 1
        else:    
            classCounts[aroClass][i] += int(n)

# print counts
out.write('ARO_class')
for h in headers[8:]:
    out.write(f'\t{h}')
out.write('\n')

for c in classCounts.keys():
    out.write(f'{c}')
    for n in classCounts[c]:
        out.write(f'\t{n}')
    out.write('\n')

out.close()
