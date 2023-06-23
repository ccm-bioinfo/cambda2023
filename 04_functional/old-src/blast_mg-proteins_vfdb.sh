#!/bin/bash

# Entrada:  Archivos .faa de prokka en data/02-annotations/01-prokka/
#           01-metagenomes/[nombre].faa

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

# Correr blastp en cada ensamblado, iniciando por los archivos más pequeños
ls -Sr data/02-annotations/01-prokka/01-metagenomes/*.faa | while read mg_assembly; do

  base=$(basename ${mg_assembly%%.faa})

  if [[ ! -f data/06-VFDB/blast/${base}.tsv ]]; then

    echo $(date) ${base}

    blastp -num_threads 16 -query ${mg_assembly} \
      -db data/06-VFDB/database/VFDB_setB_pro.fas \
      -outfmt "6 qseqid sseqid evalue pident stitle" \
      -out data/06-VFDB/blast/${base}.tsv
  
    # Agregar nombres de columnas al output
    sed -i '1s/^/qseqid\tsseqid\tevalue\tpident\tstitle\n/' data/06-VFDB/blast/${base}.tsv
  
  fi
done
