#!/bin/bash

# Entrada:  Archivos .gff de prokka en data/02-annotations/01-prokka/
#           01-metagenomes/[nombre].gff

# Salida:   Resultado de correr blastp sobre los archivos usando la base de
#           datos de VFDB encontrada en data/06-VFDB/database/, creando tablas
#           TSV en data/06-VFDB/blast/[nombre].tsv con cinco columnas:
#             qseqid: id del archivo faa
#             sseqid: id de la base de datos
#             evalue: e value
#             pident: porcentaje de identidad
#             stitle: función predicha


# Cambiar al directorio base
cd $(dirname "$(dirname "$(readlink -f $0)")")



# If basename hasn't been annotated yet
if [[ ! -d metacyc/${1} ]]; then

  echo $(date) ${1} started >> jobsmetacyc.txt

  # Perform annotation with Prokka on basename
  prokka --outdir metacyc/${1} --norrna --notrna --prefix ${1} \
    --metagenome --cpus 32 assembled/${1}.fasta

  # Get ec numbers from GFF file
  grep "eC_number=" metacyc/${1}/${1}.gff | cut -f9 | cut -f1,2 -d ';' \
    | sed 's/ID=//g' | sed 's/;eC_number=/\t/g' > metacyc/${1}/${1}.ec

  # Predict metacyc pathways with MinPath
  python3 minpath/MinPath.py -any metacyc/${1}/${1}.ec \
    -map src/mappings/map.txt -report metacyc/${1}/${1}.minpath

  # Map trimmed reads to assembly
  bowtie2-build --threads 32 assembled/${1}.fasta metacyc/${1}/${1}.fasta
  bowtie2 --threads 32 -x metacyc/${1}/${1}.fasta -1 trimmed/${1}_1.fastq.gz \
    -2 trimmed/${1}_2.fastq.gz -S metacyc/${1}/${1}.map.sam
  samtools faidx assembled/${1}.fasta -o metacyc/${1}/${1}.fasta.fai
  samtools view --threads 32 -bt metacyc/${1}/${1}.fasta.fai \
    metacyc/${1}/${1}.map.sam > metacyc/${1}/${1}.map.bam
  samtools sort -@ 32 metacyc/${1}/${1}.map.bam -o metacyc/${1}/${1}.map.sorted.bam
  samtools index -@ 32 metacyc/${1}/${1}.map.sorted.bam

  # Remove duplicates
  picard -Xmx2g MarkDuplicates \
    INPUT=metacyc/${1}/${1}.map.sorted.bam \
    OUTPUT=metacyc/${1}/${1}.map.markdup.bam \
    METRICS_FILE=metacyc/${1}/${1}.map.markdup.metrics \
    AS=TRUE VALIDATION_STRINGENCY=LENIENT \
    MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000 REMOVE_DUPLICATES=TRUE

  # Calculate coverage
  grep -v "#" metacyc/${1}/${1}.gff | grep "ID=" | cut -f1 -d ';' \
    | sed 's/ID=//g' | awk -v OFS='\t' '{print $1, $4-1, $5,$9}' \
    > metacyc/${1}/${1}.map.bed
  bedtools coverage -hist -a metacyc/${1}/${1}.map.bed -b metacyc/${1}/${1}.map.markdup.bam > metacyc/${1}/${1}.map.hist
  ./src/get-coverage-for-genes.py -i <(echo metacyc/${1}/${1}.map.hist) > metacyc/${1}/${1}.coverage

  # Create KRONA tables
  ./src/genes-to-krona.py -i metacyc/${1}/${1}.ec \
    -m src/mappings/map.txt \
    -H src/mappings/hierarchy.txt \
    -n ${1} -l <(grep "minpath 1" metacyc/${1}/${1}.minpath) \
    -c metacyc/${1}/${1}.coverage -o metacyc/${1}/${1}.minpath.tsv

  # Create KRONA HTML files
  ktImportText -o metacyc/${1}/${1}.minpath.html metacyc/${1}/${1}.minpath.tsv

  # Remove unnecessary files
  find metacyc/${1}/ -type f ! -name '*.minpath.*' -delete

  echo $(date) ${1} finished >> jobsmetacyc.txt

fi >> logs/func-annotator/${1}.log 2>&1
