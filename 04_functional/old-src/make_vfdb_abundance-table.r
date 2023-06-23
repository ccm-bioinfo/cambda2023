
library(tidyverse)
# Asignar rutas  ----------------------------------------------------------####
files <- dir(
  path = "/home/2022_15/c23-func/data/06-VFDB/blast",
  pattern ="*.tsv")
final_files<-paste0(
  "/home/2022_15/c23-func/data/06-VFDB/blast/", files)
# Importar datos ----------------------------------------------------------####
blast_out<-final_files %>%
          map_dfr(read_table2, col_names = T) %>%
          filter(pident >= 70)  %>%
          separate(qseqid, c("Metagenoma","dos"))
# Agregar la ciudad -------------------------------------------------------####
Ciudades<-read_tsv(
  "/home/2022_15/c23-func/data/02-annotations/02-kegg/01-metagenomes/id_list",
  col_names = F) %>%
  rename(Protein_name = X2) %>%
  rename(Ciudad = X1) %>%
  separate(Protein_name, c("Metagenoma", "dos"), 
           sep = "_") %>%
  select(Ciudad, Metagenoma) %>%
  distinct() 
# Juntar tablas -----------------------------------------------------------####
 juntos<-blast_out %>%
  left_join(Ciudades, by="Metagenoma") %>%
  select(stitle, Ciudad) %>%
  group_by(Ciudad) %>%
  count(stitle)

final_vfdb<-juntos %>%
   pivot_wider(names_from = Ciudad, values_from = n, values_fill = 0)
# Escribir tabla  ---------------------------------------------------------####
write_tsv(final_vfdb, 
"/home/2022_15/c23-func/data/06-VFDBvfdb_table.tsv")