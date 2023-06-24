#!/usr/bin/env Rscript
library("optparse")

option_list = list(
    make_option(c("-I", "--inputdir"), type = "character", default = "~/c23/taxonomy/", 
                help = "input directory [default= %default]", metavar = "character"),
    make_option(c("-O", "--outdir"), type = "character", default = "~/c23/taxonomy-levels/", 
                help = "output directory [default= %default]", metavar = "character"),
    make_option(c("-r", "--reads"), type = "logical", default = TRUE,
                help = "reads or assembly [default= %default]", metavar = "logical")
); 

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

# 03 june 2023
# jose maria ibarra / Nelly Sélem  
# 19 june 2023
# Imanol Nuñez

# -------------------------------------------------------------------------
# count tables of each taxonomical level

# libraries ---------------------------------------------------------------
library("phyloseq") 
# paths ---------------
inputdir <- opt$inputdir
setwd(inputdir)
outdir <- opt$outdir
dir.create(outdir, recursive = TRUE)

# Variable string
filename <- ifelse(opt$reads,
                   "read-biom.json",
                   "assembly-biom.json")
# Concatenate variable and path
inpath <- paste(inputdir, filename, sep = "")

# Preprocessing -----------------------------------------------------------

# 1 biom.tsv to .biom

# in terminal :
# go to taxonomy/assembly-level/

# conda activate metagenomics
# kraken-biom *report --fmt json -o camda.biom

# go to /taxonomy/assembly-level/
# kraken-biom *report --fmt json -o reads_level.biom

# Esto nos da una tabla biom que ya podemos cortar en phyloseq

#################  Read data #################################
# read biom from reads level
reads_biom <- import_biom(inpath)
## Correct names in taxonomic table
# assign new names
colnames(reads_biom@tax_table@.Data) <- c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species")
# eliminate extra characters in the beginning of each entry
reads_biom@tax_table@.Data <- substring(reads_biom@tax_table@.Data, 4)
#View(reads_biom@tax_table@.Data)


################ Function to Extract  by taxonomic levels --------------------------------------------
# TEST
### PLAN
# For 
# a) All data together
# b) Archea and Bacteria
# c) Eukaryota
# d) Viruses
# Create count table and tax table (dictionary) as data frames for this taxonomical levels:
# "Phylum", "Class", "Order", "Family", "Genus", "Species"

#  All reads --------------------------------------------------------------

# conglomerate to phylum level
# Function to calculate the factorial of a number
agglomerate <- function(phobject,outdir,leveling,prefix) {
  
  file_read_count<-paste(outdir,prefix,"_count_", "_",leveling,".csv", sep = "")
  file_Dict_count<-paste(outdir,prefix,"_taxDict_", "_",leveling,".csv", sep = "")
  
  reads_glom <- tax_glom(phobject, taxrank = leveling)
  #View(reads_glom_phylum@otu_table@.Data)
  
  # to data frame 
  reads.df = as.data.frame(reads_glom@otu_table)
  reads_tax.df = as.data.frame(reads_glom@tax_table)
  
  write.csv(reads.df,file_read_count)
  write.csv(reads_tax.df,file_Dict_count)
}

########## ----------------------------------------------
# Create a list
tax_levels <- list("Phylum", "Class", "Order", "Family", "Genus")

# Concatenate variable and path
prefix0 <- ifelse(opt$reads, "reads", "assembly")  # label to relate files to filename
cat(sprintf("Working with %s data\n", prefix0))
cat(sprintf("Using all data\n"))
lapply(tax_levels, function(x) agglomerate(reads_biom, outdir, x, prefix0))

###  Archaea and Bacteria ----------------------------------------------------
cat(sprintf("Using AB data\n"))
readsArchaeaBacteria <- subset_taxa(reads_biom, Kingdom %in% c("Archaea", "Bacteria"))
prefix <- paste0(prefix0, "AB")
lapply(tax_levels, function(x) agglomerate(readsArchaeaBacteria, outdir, x, prefix))

#### ---------
cat(sprintf("Using Eukaryota data\n"))
readsEukaryota <- subset_taxa(reads_biom, Kingdom == "Eukaryota")
prefix <- paste0(prefix0, "Eukarya")
lapply(tax_levels, function(x) agglomerate(readsEukaryota, outdir, x, prefix))

###  Viruses ----------------------------------------------------
cat(sprintf("Using Viruses data\n"))
readsViruses <- subset_taxa(reads_biom, Kingdom == "Viruses")
prefix <- paste0(prefix0, "Viruses")
lapply(tax_levels, function(x) agglomerate(readsViruses, outdir, x, prefix))


### OPTIONAL PREPROCESSING
###Cargar metadatos 
### metadata_camda <- read.csv2("/home/camila/GIT/Tesis_Maestria/Data/fresa_solena/Data1/metadata.csv",header =  FALSE, row.names = 1, sep = ",")
###  reads_biom@sam_data <- sample_data(metadata_camda)
#### reads_biom@sam_data$Sample<-row.names(reads_biom@sam_data)

# colnames(fresa_kraken@sam_data)<-c('Treatment','Samples')
# fresa_kraken_fil <- prune_samples(!(sample_names(fresa_kraken) %in% samples_to_remove), fresa_kraken)

## Convertir a abundancias relativas  
### percentages_fil <- transform_sample_counts(fresa_kraken_fil, function(x) x*100 / sum(x) )
### percentages_df <- psmelt(percentages_fil)

