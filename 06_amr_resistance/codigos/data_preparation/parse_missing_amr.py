misteryFile = open('amr_patterns.tsv','r')
headers = misteryFile.readline()

# get list of all amr markers in all the samplesmissingAmrFile = open('missingAmr.txt.','r')
missingAmrFile = open('missingAmr.txt.','r')
missing = missingAmrFile.read().split('\n')
amrSet = set()

out = open('missingAmr_species.tsv','w')
for sample in misteryFile:
    id, species, astGroup, amrSample = sample.replace('\n','').lower().split('\t')
    amrSampleList = amrSample.split(', ')
    for m in missing:
        if m in amrSampleList:
            out.write(f'{m}\t{species}\n')

out.close()
misteryFile.close()
missingAmrFile.close()
