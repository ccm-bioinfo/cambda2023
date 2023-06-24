# cargamos librerias
library("phyloseq")
library("ggplot2")
library("igraph")
library("vegan")
library(readr)
library(dplyr)
library("GUniFrac")
library("pbkrtest")
library("phyloseq")
library("RColorBrewer")
library("patchwork")
#library("BiodiversityR")
#
setwd("/home/shaday/GIT/ccm-bioinfomatica-lab/Hackaton_junio2023/Resistencia")

#### leer archivos de metadatos
meta <- read_csv("data/metadata-assembly.csv")
View(meta)
##importar los biom
Camda=import_biom("data/assembly_365_2.biom")
Camda2=import_biom("data/read_365_2.biom")
###Funcion para crea tablas de ambundacias adsolutas y relativas de otus, pegadas con los metadatos
metadata<- function(biom_file, meta_data){
  biom_file@tax_table@.Data <- substring(biom_file@tax_table@.Data, 4) #cut the firts character of tax
  colnames(biom_file@tax_table@.Data)<- c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species")
  
  absolute_order <- tax_glom(biom_file, taxrank = 'Order') # glom to Order level
  percentages_order <- transform_sample_counts(absolute_order, function(x) x / sum(x) ) #
  
  otu_order_absolute=t(absolute_order@otu_table@.Data)
  otu_order_relative=t(percentages_order@otu_table@.Data)
  
  otu_order_absolute=data.frame(otu_order_absolute)
  meta=data.frame(meta)
  df_complete_order_absolute=cbind(meta_data,otu_order_absolute)
  
  otu_order_relative=data.frame(otu_order_relative)
  meta=data.frame(meta_data)
  df_complete_order_relative=cbind(meta_data,otu_order_relative)
  
  write_csv(df_complete_order_absolute, "data/absolute_order_assembly.csv", col_names = TRUE)
  write_csv(df_complete_order_relative, "data/relative_order_assembly.csv", col_names = TRUE)
}
metadata(biom_file = Camda,meta_data = meta)



