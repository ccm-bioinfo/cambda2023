# Script para leer la salida de KofamScan.
# El script calcula la abundancia de cada KO 
# sumando el número de veces que aparece en un metagenoma.
# Como dato de entrada, necesitamos la ruta a los resultados de KofamScan.
# Como salida, obtenemos una tabla de donde las columnas son los sitios
# y las filas las funciones.

# Uso: rscript make_kegg_abundance-table.r

library(tidyverse)
# Asignar rutas  ----------------------------------------------------------####
files <- dir(
  path = "/home/2022_15/c23-func/data/02-annotations/02-kegg/01-metagenomes",
  pattern ="*.txt")
final_files<-paste0(
  "/home/2022_15/c23-func/data/02-annotations/02-kegg/01-metagenomes/", files)
# Importar datos y calcular abundancia ------------------------------------####
KO_raw<-final_files %>%
          map_dfr(read_table2, col_names = F) %>%
          filter(str_detect(X1, '\\*')) %>%
          select(X2, X3) %>%
          rename(Metagenoma = X2) %>%
          rename(KO = X3) %>% 
  separate(Metagenoma, c("Metagenoma", "Protein_name"), 
           sep = "[_][[:digit:]]") %>%
  unite("Protein_name", c("Metagenoma", "Protein_name"), remove = FALSE)

KO_abundance <- KO_raw %>%
  group_by(Metagenoma) %>%
  distinct() %>%
  count(KO) %>%
  rename(Abundance = n) %>%
  ungroup()

final_table_1 <- left_join(KO_raw, KO_abundance, 
                           by = c("Metagenoma", "KO")) %>%
  distinct()  %>%
  mutate(Protein_name = str_trim(Protein_name))

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

 juntos<-final_table_1 %>%
  left_join(Ciudades, by="Metagenoma") %>%
   select(KO, Abundance, Ciudad) %>%
   group_by(Ciudad) %>%
   count(KO)

final_kegg<-juntos %>%
   pivot_wider(names_from = Ciudad, values_from = n, values_fill = 0)
# Escribir tabla  ---------------------------------------------------------####
write_tsv(final_kegg, 
"/home/2022_15/c23-func/data/02-annotations/02-kegg/kegg_table.tsv")
