import re
import join_card_data as jc

flagAROid = True
misteryFile = open('data/amr_patterns.tsv','r')
if flagAROid:
    aro = jc.loadCard('data/aro_index.tsv')
out = open('data/amr_mistery_table20230622_aroIds.tsv','w')

headers = misteryFile.readline()
# get list of all amr markers in all the samples
amrSet = set()
for sample in misteryFile:
    id, species, astGroup, amrSample = sample[:-1].split('\t')
    amrSampleList = amrSample.lower().split(', ')
    for i in range(len(amrSampleList)):
        amrSampleList[i] = re.sub('\W+','', amrSampleList[i])
    amrSet.update(amrSampleList)

out.write('sample')
amrList = list(amrSet)

for a in amrList:
    # use to print out gene name instead of ARO id
    # out.write(f'\t{a}')
    # parse gene name to ARO id
    if flagAROid:
        if a.lower() in aro.keys():
            _, _, _, aroId = aro[a.lower()]
            out.write(f'\t{aroId}')
        else:
            out.write(f'\t{a.lower()}')
    else:
        out.write(f'\t{a.lower()}')
out.write('\n')


misteryFile.seek(0)
# skip header
misteryFile.readline()
# convert to table format
for sample in misteryFile:
    id, species, astGroup, amrSample = sample.replace('\n','').split('\t')
    out.write(f'{id}')
    amrSampleList = list()
    for amr in amrSample.split(','):
        amrSampleList.append( (re.sub('\W+','', amr)).lower() )

    for amr in amrList:
        if amr in amrSampleList:
            out.write('\t1')
        else:
            out.write('\t0')
    out.write('\n')

misteryFile.close()
out.close()
