import re

def ParseBlastToHitTable (inFileName, outFileName):
    blastFile = open(inFileName,'r')
    currentDb = ''
    out = open(outFileName,'w')
    out.write('database\tcontig amr\tamr length\tcontig length\tamr coverage\tlength\tpident')

    for line in blastFile:
    # Database: ../assemblies/CAMDA23_MetaSUB_gCSD16_AKL_1.fasta    
        if 'Database' in line:
            currentDb= line[:-1].split(': ')[1].replace('../assemblies/','')
        if line.startswith('#'):
            continue
        out.write(f'{currentDb}\t{line}')

def ParseHitToCountMatrix(inFileName, outFileName, headerList, flagPrintContig = False):
    hits = open(inFileName,'r')
    out = open(outFileName,'w')

    if flagPrintContig:
        out.write('db.contig')
    else:
        out.write('db')
    for header in headerList:
        out.write(f'\t{header}')
    out.write('\n')

    # skip header
    hits.readline()

    counts = dict()
    err = open('blastMissnomerAmr.txt','w')
    for line in hits:
        database, amrGene, contig, amrLength, contigLength, amrCoverage, hitLength, identityPercentage = line[:-1].split('\t')
        amrGene = re.sub('\W+','', amrGene)
        # hits must have > 70% identity and good coverage (either as coverage or length)
        if float(identityPercentage) < 70 or ( float(amrCoverage)<50 and float(hitLength) < 100):
            continue
        if flagPrintContig:
            name = f'{database}.{contig}'
        else:
            name = database
        if name not in counts.keys():
            counts[name] = dict()
            for gene in headerList:
                counts[name][gene] =0
        if amrGene not in headerList:
            err.write(f'{amrGene}\n')
            continue
        counts[name][amrGene] += 1
    err.close()
    for name in counts.keys():
        out.write(f'{name}')
        for gene in headerList:
            out.write(f'\t{counts[name][gene]}')
        out.write('\n')
    out.close()
    hits.close()
    
def loadHeaderList(inFileName):
# database	contig	amr	amr length	contig length	amr coverage	length	pident
# CAMDA23_MetaSUB_gCSD17_ILR_14.fasta	k141_1801	oqxb14	3153	2105	36	1168	69.349
    file = open(inFileName,'r')
    headers = file.read().split('\n')
    return headers

headerList = loadHeaderList('amrMysteryList.txt')
ParseBlastToHitTable('blastAll.txt','missing_vs_camda23_20230606.tsv')
ParseHitToCountMatrix('missing_vs_camda23_20230606.blast.tsv','amr_counts_complement.tsv', headerList, flagPrintContig=False)