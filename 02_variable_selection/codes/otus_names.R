#!/usr/bin/env Rscript
library("optparse")

option_list = list(
    make_option(c("-I", "--input_dir"), type = "character", default = "../selected_variables_results/reduced_significant_otus/", 
                help = "input directory [default= %default]", metavar = "character"),
    make_option(c("-d", "--tax_data"), type = "character", default = "../data/", 
                help = "directory where the taxonomic dictionaries are stored [default= %default]", metavar = "character"),
    make_option(c("-O", "--out_dir"), type = "character", default = "../selected_variables_results/reduced_otus_list/", 
                help = "output directory [default= %default]", metavar = "character"),
    make_option(c("-r", "--reads"), type = "logical", default = TRUE,
                help = "reads (TRUE) or assembly (FALSE) [default= %default]", 
                metavar = "logical"),
    make_option(c("-a", "--all"), type = "logical", default = TRUE, 
                help = "run with all (TRUE) kingdoms or separated (FALSE) by AB, Eu & Vi",
                metavar = "logical"),
    make_option(c("-m", "--model"), type = "character", default = "nb",
                help = "model to adjust: Poisson (p), Negative Binomial (nb), Zero Inflated Poisson (zip) or Zero Inflated Negative Binomial (zinb) [default= %default]",
                metavar = "integer")
); 

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

# 25 june 2023
# Imanol Nuñez

#-------------------------------------------------------------------------------
# Load libraries via pacman
pacman::p_load(dplyr, tibble, tidyr)

#-------------------------------------------------------------------------------
# Prepare the data reading 
path_to_input <- opt$input_dir
path_to_output <- opt$out_dir
prefix0 <- ifelse(opt$reads, "reads", "assembly")
prefix1 <- ifelse(opt$all, "", "kingdoms")
prefix2 <- opt$model

# Reading the data
signif_otus_best <- read.csv(
    paste0(path_to_input, prefix0, "_", prefix1, "_", prefix2, "_signif_reduced.csv")
)

# Get the different taxonomic levels present in the data
taxLevels <- unique(unlist(signif_otus_best$hlevel))

sepList <- vector("list", length = length(taxLevels))
for (i in 1:length(taxLevels)) {
    # get the taxons corresponding to a taxonomic level
    signif_temp <- signif_otus_best %>% 
        filter(hlevel == taxLevels[i])
    # Get the taxonomic names of the selected OTUs
    tempData <- read.csv(
        paste0(
            opt$tax_data, prefix0, "/", prefix0, "_taxDict__",  
            sub('.*_(.*)', '\\1', taxLevels[i], perl = TRUE), ".csv"
        )
    ) %>% 
        filter(X %in% unlist(signif_temp$OTU)) %>% 
        rename(OTU = X)
    # Add the names of the OTUs to the tables
    sepList[[i]] <- signif_temp %>% 
        left_join(tempData, by = "OTU")
}

# Join the data with taxonomic names
signif_otus_best_names <- sepList[[1]]
if (length(taxLevels) > 1) {
    for (i in 2:length(taxLevels)) {
        signif_otus_best_names <- signif_otus_best_names %>% 
            full_join(sepList[[i]])
    }
}

# Deleting columns that are not useful
signif_otus_best_names <- signif_otus_best_names %>% 
    select(-c(
        "pvalues", "model", "score", "adj_pvalues", "OtuClass", "loc1", "loc2", 
        "Species"
    ))

# Order the columns according to OTUs and the taxonomic level (useful to see if 
# nesting is present)
signif_otus_best_names %>% 
    arrange(
        OTU, 
        factor(hlevel, levels = c(
            "_Phylum", "_Class", "_Order", "_Family", "_Genus",
            "AB_Phylum", "AB_Class", "AB_Order", "AB_Family", "AB_Genus",
            "Eukarya_Phylum", "Eukarya_Class", "Eukarya_Order", "Eukarya_Family", "Eukarya_Genus",
            "Viruses_Phylum", "Viruses_Class", "Viruses_Order", "Viruses_Family", "Viruses_Genus"
        ))
    ) %>% 
    write.csv(
        file = paste0(
            path_to_output, "otus_", prefix0, "_", prefix1, "_", prefix2, 
            ".csv"
        ),
        row.names = FALSE
    )
# Save the produced table