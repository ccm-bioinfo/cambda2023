#!/usr/bin/env Rscript
library("optparse")

option_list = list(
    make_option(c("-I", "--input_dir"), type = "character", default = "../selected_variables_results/pValues/", 
                help = "input directory [default= %default]", metavar = "character"),
    make_option(c("-d", "--tax_data"), type = "character", default = "../data/", 
                help = "directory where the taxonomic dictionaries are stored [default= %default]", metavar = "character"),
    make_option(c("-O", "--out_dir"), type = "character", default = "../selected_variables_results/sign_otus_by_kingdom/", 
                help = "output directory [default= %default]", metavar = "character"),
    make_option(c("-r", "--reads"), type = "logical", default = TRUE,
                help = "reads (TRUE) or assembly (FALSE) [default= %default]", 
                metavar = "logical"),
    make_option(c("-k", "--best_k"), type = "integer", default = 5, 
                help = "number of significant OTUs", metavar = "integer"),
    make_option(c("-m", "--model"), type = "character", default = "nb",
                help = "model to adjust: Poisson (p), Negative Binomial (nb), Zero Inflated Poisson (zip) or Zero Inflated Negative Binomial (zinb) [default= %default]",
                metavar = "integer"),
    make_option(c("-v", "--validation"), type = "character", default = NULL, 
                help = "path to a file which specifies the validation samples",
                metavar = "character")
); 

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

# 3 july 2023
# Imanol Nuñez

#-------------------------------------------------------------------------------
# Load libraries via pacman
pacman::p_load(ggplot2, ggthemes,                       # Plots
               dplyr, tibble, tidyr, purrr, broom, pscl)                 # Data frame manipulation 

#-------------------------------------------------------------------------------
# Given a table of p-values, getKOtus gets the k most significant OTUs 
# for each pair of city/year, specifying the hierarchical level of said OTU
getKOtus <- function(db, k) {
    # Put all p-values into a single column, identifying them by the cities 
    # being contrasted
    #    pValueslong <- db %>% 
    #    pivot_longer(cols = -c("OTU", "hlevel"), 
    #                 names_to = "cities", 
    #                 values_to = "p-value") %>% 
    #    mutate(city1 = substr(cities, 1, 5), city2 = substr(cities, 10, 15))
    
    # Which comparisons were made
    comparisons <- unique(unlist(db$locs))
    # Initialize the data frame for the k most significant OTUs per 
    # city vs city contrast
    reducedK <- data.frame(
        OTU = integer(), pvalues = double(), model = character(), 
        score = double(), loc1 = character(), 
        loc2 = character(), locs = character(), adj_pvalues = double(),  
        hlevel = character(), sign_rank = integer()
    )
    # Get the significant OTus
    for(i in 1:length(comparisons)) {
        tempData <- db %>% 
            filter(locs == comparisons[i]) %>% 
            arrange(adj_pvalues) %>% 
            head(n = k) %>% 
            mutate(sign_rank = 1:k)
        reducedK <- reducedK %>% 
            full_join(tempData, by = c(
                "OTU", "pvalues", "model", "score", "loc1", "loc2", "locs", "adj_pvalues",
                "hlevel", "sign_rank"
            ))
    }
    
    # Add an ID for OTU - class
    reducedK <- reducedK %>% 
        mutate(OtuClass = paste(OTU, hlevel, sep = ""))
    
    return(reducedK)
}

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
# Get the taxonomic data for the OTUs
taxonomicDataSignificantOTUs <- function(db, path_to_data) {
    # Get the different taxonomic levels present in the data
    taxLevels <- unique(unlist(db$hlevel))
    
    sepList <- vector("list", length = length(taxLevels))
    for (i in 1:length(taxLevels)) {
        # get the taxons corresponding to a taxonomic level
        signif_temp <- db %>% 
            filter(hlevel == taxLevels[i])
        # Get the taxonomic names of the selected OTUs
        tempData <- read.csv(
            paste0(
                path_to_data, prefix0, "/", prefix0, "_taxDict__",  
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
        )
}

#-------------------------------------------------------------------------------
# Test
prefix0 <- ifelse(opt$reads, "reads", "assembly")
prefix1 <- "kingdoms"
path_to_counts <- opt$input_dir
if (is.null(opt$validation)) {
    cat(sprintf("There is no validation data set\n"))
    train_cols <- NULL
    suffix0 <- ""
} else {
    cat(sprintf("There is a validation data set\n"))
    train_val_set <- read.csv(opt$validation)
    train_cols <- train_val_set$Num_Col[train_val_set$Train == 1]
    suffix0 <- "_tv"
}

pValues <- read.csv(
    paste0(path_to_counts, prefix0, "_", prefix1, "_", opt$model, 
           "_pvalues", suffix0, ".csv.gz")
)

pValues_AB <- pValues %>% 
    filter(sub('(.*)_.*', '\\1', hlevel, perl = TRUE) == "AB")

pValues_Eukarya <- pValues %>% 
    filter(sub('(.*)_.*', '\\1', hlevel, perl = TRUE) == "Eukarya")

pValues_Viruses <- pValues %>% 
    filter(sub('(.*)_.*', '\\1', hlevel, perl = TRUE) == "Viruses")

sign_otus_AB <- pValues_AB %>% 
    getKOtus(k = opt$best_k)

sign_otus_Eukarya <- pValues_Eukarya %>% 
    getKOtus(k = opt$best_k)

sign_otus_Viruses <- pValues_Viruses %>% 
    getKOtus(k = opt$best_k)

reduced_sign_otus_AB <- unnestingOtus(sign_otus_AB)

reduced_sign_otus_Eukarya <- unnestingOtus(sign_otus_Eukarya)

reduced_sign_otus_Viruses <- unnestingOtus(sign_otus_Viruses)

taxData_AB <- taxonomicDataSignificantOTUs(reduced_sign_otus_AB, opt$tax_data)

taxData_Eukarya <- taxonomicDataSignificantOTUs(reduced_sign_otus_Eukarya, opt$tax_data)

taxData_Viruses <- taxonomicDataSignificantOTUs(reduced_sign_otus_Viruses, opt$tax_data)

write.csv(
    reduced_sign_otus_AB, 
    file = paste0(opt$out_dir, prefix0, "_AB_", opt$model, "_sign_otus.csv")
)
write.csv(
    taxData_AB, 
    file = paste0(opt$out_dir, prefix0, "_AB_", opt$model, "_sign_otus_tax.csv")
)
write.csv(
    reduced_sign_otus_Eukarya, 
    file = paste0(opt$out_dir, prefix0, "_Eukarya_", opt$model, "_sign_otus.csv")
)
write.csv(
    taxData_Eukarya, 
    file = paste0(opt$out_dir, prefix0, "_Eukarya_", opt$model, "_sign_otus_tax.csv")
)
write.csv(
    reduced_sign_otus_Viruses, 
    file = paste0(opt$out_dir, prefix0, "_Viruses_", opt$model, "_sign_otus.csv")
)
write.csv(
    taxData_Viruses, 
    file = paste0(opt$out_dir, prefix0, "_Viruses_", opt$model, "_sign_otus_tax.csv")
)