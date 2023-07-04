#!/usr/bin/env Rscript
library("optparse")

option_list = list(
    make_option(c("-d", "--tax_data"), type = "character", default = "../selected_variables_results/otus_taxonomic/", 
                help = "directory where the taxonomic dictionaries are stored [default= %default]", metavar = "character"),
    make_option(c("-O", "--out_dir"), type = "character", default = "../selected_variables_results/most_differential_otus/", 
                help = "output directory [default= %default]", metavar = "character"),
    make_option(c("-r", "--reads"), type = "logical", default = TRUE,
                help = "reads (TRUE) or assembly (FALSE) [default= %default]", 
                metavar = "logical"),
    make_option(c("-k", "--kingdoms"), type = "logical", default = FALSE, 
                help = "kingdoms", metavar = "logical"),
    make_option(c("-R", "--reduced"), type = "logical", default = FALSE, 
                help = "reduced data", metavar = "logical"),
    make_option(c("-m", "--model"), type = "character", default = "nb",
                help = "model to adjust: Poisson (p), Negative Binomial (nb), Zero Inflated Poisson (zip) or Zero Inflated Negative Binomial (zinb) [default= %default]",
                metavar = "integer"),
    make_option(c("-u", "--usa"), type = "logical", default = FALSE, 
                help = "relevant for USA", metavar = "logical"),
    make_option(c("-D", "--differential"), type = "integer", default = 10,
                help = "When is an OTU deemed most differential?", metavar = "integer")
); 

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

# 4 july 2023
# Imanol Nuñez
#-------------------------------------------------------------------------------
# Load libraries via pacman
pacman::p_load(dplyr, tibble, tidyr)                 # Data frame manipulation 

#-------------------------------------------------------------------------------
# Identify the most differential OTUs
prefix0 <- ifelse(opt$reads, "reads", "assembly")
prefix1 <- ifelse(opt$kingdoms, "kingdoms", "")
prefix2 <- opt$model
suffix0 <- ifelse(opt$reduced, "_reduced", "")
suffix1 <- ifelse(opt$usa, "_usa", "")

path_to_tax <- paste0(
    opt$tax_data, "otus_", prefix0, "_", prefix1, "_", 
    prefix2, "_tax", suffix0, ".csv"
)

path_to_tab <- paste0(
    opt$out_dir, prefix0, "_", prefix1, "_", prefix2, "_mostDiff", suffix0
    , suffix1, ".csv"
)

tax_selected_variables <- read.csv(
    path_to_tax
) %>% 
    distinct()

if (opt$usa) {
    tax_selected_variables <- tax_selected_variables %>% 
        mutate(
            loc1 = substr(locs, 1, 3), 
            loc2 = substr(locs, 10, 12)
        ) %>% 
        filter(
            ( grepl("BAL", loc1) | grepl("DEN", loc1) | grepl("MIN", loc1) | 
                  grepl("NYC", loc1) | grepl("SAC", loc1) | grepl("SAN", loc1) ) &  
                ( grepl("BAL", loc2) | grepl("DEN", loc2) | grepl("MIN", loc2) | 
                      grepl("NYC", loc2) | grepl("SAC", loc2) | grepl("SAN", loc2) )
        ) %>% 
        select(-c("loc1", "loc2"))
}

tax_witouth_locations <- tax_selected_variables %>% 
    select(-c("locs", "sign_rank")) %>% 
    distinct() %>% 
    mutate(
        hlevel = factor(hlevel, levels = c(
            "_Phylum", "_Class", "_Order", "_Family", "_Genus",
            "AB_Phylum", "AB_Class", "AB_Order", "AB_Family", "AB_Genus",
            "Eukarya_Phylum", "Eukarya_Class", "Eukarya_Order", "Eukarya_Family", "Eukarya_Genus",
            "Viruses_Phylum", "Viruses_Class", "Viruses_Order", "Viruses_Family", "Viruses_Genus"
        ))
    ) %>% 
    group_by(OTU) %>% 
    slice(which.max(hlevel)) %>% 
    ungroup()

otuCounts <- table(tax_selected_variables$OTU)

most_diff_otus <- otuCounts[otuCounts > opt$differential]

tax_diff_otus <- tax_witouth_locations[
    tax_witouth_locations$OTU %in% as.integer(names(most_diff_otus)), 
] %>% 
    mutate(Comparisons = as.vector(most_diff_otus)) %>%
    select(-hlevel) %>% 
    relocate(Comparisons, .after = OTU)

write.csv(
    tax_diff_otus,
    file = path_to_tab,
    row.names = FALSE
)
