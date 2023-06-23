#!/bin/bash

# Entrada:  Base de datos de VFDB encontrada en data/06-VFDB/database/
#           VFDB_setB_pro.fas

# Salida:   Bases de datos en formato para proteínas en data/06-VFDB/database/


# Cambiar al directorio base
cd $(dirname "$(dirname "$(readlink -f $0)")")

# Crear bases de datos de blastp
makeblastdb -in data/06-VFDB/database/VFDB_setB_pro.fas -dbtype prot
