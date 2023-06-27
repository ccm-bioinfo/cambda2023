#!/usr/bin/env Rscript
library("optparse")

option_list = list(
    make_option(c("-i", "--sign_path"), type = "character",
                default = "../selected_variables_results/significant_otus/", 
                help = "path to the original significant OTUs", metavar = "character"),
    make_option(c("-I", "--input_dir"), type = "character", default = "../data/", 
                help = "input directory [default= %default]", metavar = "character"),
    make_option(c("-O", "--out_dir"), type = "character", default = "../selected_variables_results/", 
                help = "output directory [default= %default]", metavar = "character"),
    make_option(c("-r", "--reads"), type = "logical", default = TRUE,
                help = "reads (TRUE) or assembly (FALSE) [default= %default]", 
                metavar = "logical"),
    make_option(c("-a", "--all"), type = "logical", default = TRUE, 
                help = "run with all (TRUE) kingdoms or separated (FALSE) by AB, Eu & Vi",
                metavar = "logical"),
    make_option(c("-m", "--model"), type = "character", default = "nb",
                help = "model to adjust: Poisson (p), Negative Binomial (nb), Zero Inflated Poisson (zip) or Zero Inflated Negative Binomial (zinb) [default= %default]",
                metavar = "integer"),
    make_option(c("-v", "--validation"), type = "logical", default = FALSE, 
                help = "was there a validation data set",
                metavar = "character")
); 

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

# 26 june 2023
# Imanol Nuñez

#-------------------------------------------------------------------------------
# Load libraries via pacman
pacman::p_load(ggplot2, ggthemes,                       # Plots
               dplyr, tibble, tidyr)                 # Data frame manipulation 
# library(ggplot2)
# library(ggthemes)
# library(dplyr)
# library(tibble)
# library(tidyr)

#-------------------------------------------------------------------------------
# Given a list of significant OTUs, we keep only the lowest taxonomic level 
# to avoid nesting in a pair of cities
unnestingOtus <- function(sign_otus) {
    sign_otus_reduced <- sign_otus %>% 
        mutate(
            hlevel = factor(hlevel, levels = c(
                "_Phylum", "_Class", "_Order", "_Family", "_Genus",
                "AB_Phylum", "AB_Class", "AB_Order", "AB_Family", "AB_Genus",
                "Eukarya_Phylum", "Eukarya_Class", "Eukarya_Order", "Eukarya_Family", "Eukarya_Genus",
                "Viruses_Phylum", "Viruses_Class", "Viruses_Order", "Viruses_Family", "Viruses_Genus"
            ))
        ) %>% 
        group_by(OTU, locs) %>% 
        slice(which.max(hlevel)) %>% 
        ungroup()
    return(sign_otus_reduced)
}

#-------------------------------------------------------------------------------
# Given a list of significant OTUs, construct the integrated sample with only 
# these OTUs. 
constructIntegratedData <- function(sign_otus, path_to_counts, reads = TRUE) {
    hLevels <- unique(sign_otus$hlevel)
    # Initialize a list where the subsetting will be done by taxonomical levels
    dataSubsets <- vector("list", length(hLevels))
    for (i in 1:length(hLevels)) {
        if (reads) {
            tempData <- read.csv(
                paste0(path_to_counts, "reads", 
                       sub('(.*)_.*', '\\1', hLevels[i], perl = TRUE), 
                       "_count__", 
                       sub('.*_(.*)', '\\1', hLevels[i], perl = TRUE), 
                       ".csv")
            )
        } else {
            tempData <- read.csv(
                paste0(path_to_counts, "assembly", 
                       sub('(.*)_.*', '\\1', hLevels[i], perl = TRUE), 
                       "_count__", 
                       sub('.*_(.*)', '\\1', hLevels[i], perl = TRUE), 
                       ".csv")
            )
        }
        # Subset which significant OTUs correspond to a given taxonomical 
        # level
        tempOTUs <- sign_otus %>%  
            filter(hlevel == hLevels[i])
        # Subset those significant OTUs from the count data 
        dataSubsets[[i]] <- tempData[tempData[, 1] %in% tempOTUs$OTU, ] %>% 
            mutate(hlevel = hLevels[i]) %>% 
            rename("OTU" = "X")
    }
    # Merge all of the subsetted data
    retDF <- dataSubsets[[1]]
    if (length(hLevels) > 1) {
        for (i in 2:length(hLevels)) {
            retDF <- retDF %>% 
                full_join(dataSubsets[[i]])
        }
    }
    # 
    retDF <- retDF %>% 
        mutate(ID = paste0(OTU,"_", hlevel)) %>% 
        dplyr::select(-c("OTU", "hlevel")) %>% 
        relocate(ID)
    return(retDF)
}

#-------------------------------------------------------------------------------
# Test
prefix0 <- ifelse(opt$reads, "reads", "assembly")
prefix1 <- ifelse(opt$all, "", "kingdoms")
prefix2 <- opt$model
path_to_counts <- paste0(opt$input_dir, prefix0, "/")
suffix0 <- ifelse(opt$validation, "_tv", "")
suffix1 <- "_reduced"

orig_sign_otus <- read.csv(paste0(
    opt$sign_path, prefix0, "_", prefix1, "_", prefix2, "_signif.csv"
))
reduced_sign_otus <- unnestingOtus(orig_sign_otus)
reduced_integrated_table <- constructIntegratedData(
    reduced_sign_otus, path_to_counts, opt$reads
)

write.csv(
    reduced_sign_otus,  
    file = paste0(
        opt$out_dir, "reduced_significant_otus/", prefix0, "_", prefix1, "_", 
        prefix2, "_", "signif", suffix0, suffix1, ".csv"
    ),
    row.names = FALSE
)

write.csv(
    reduced_integrated_table,  
    file = paste0(
        opt$out_dir, "integrated_reduced_tables/", prefix0, "_", prefix1, "_", 
        prefix2, "_", "integrated", suffix0, suffix1, ".csv"
    ),
    row.names = FALSE
)