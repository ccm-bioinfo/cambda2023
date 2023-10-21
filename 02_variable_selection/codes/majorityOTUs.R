#!/usr/bin/env Rscript
#install.packages("optparse", repos = "http://cran.us.r-project.org", lib = "./libs")
#install.packages("pacman", repos = "http://cran.us.r-project.org", lib = "./libs")
#library("optparse", lib.loc = "./libs")
#library("pacman", lib.loc = "./libs")
pacman::p_load(optparse)

option_list = list(
    make_option(c("-o", "--original"), type = "character", default = TRUE, 
                help = "input directory [default= %default]", metavar = "character"),
    make_option(c("-O", "--out_dir"), type = "character", default = "../selected_variables_results/majorityOTUs/", 
                help = "output directory [default= %default]", metavar = "character"),
    make_option(c("-r", "--reads"), type = "logical", default = TRUE,
                help = "reads (TRUE) or assembly (FALSE) [default= %default]", 
                metavar = "logical"),
    make_option(c("-a", "--all"), type = "logical", default = FALSE, 
                help = "run with all (TRUE) kingdoms or separated (FALSE) by AB, Eu & Vi",
                metavar = "logical"),
    make_option(c("-m", "--model"), type = "character", default = "nb",
                help = "adjusted model: Poisson (p), Negative Binomial (nb), Zero Inflated Poisson (zip) or Zero Inflated Negative Binomial (zinb), best [default= %default]",
                metavar = "integer"),
    make_option(c("-t", "--taxa"), type = "character", default = "all", 
                help = "use taxa?", metavar = "character"),
    make_option(c("-p", "--perc"), type = "numeric", default = 100, 
                help = "percentage of samples where OTU is located",
                metavar = "numeric")
); 

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

# 19 october 2023
# Imanol Nuñez

#-------------------------------------------------------------------------------
# Load libraries via pacman
pacman::p_load(ggplot2, ggthemes,                       # Plots
                dplyr, tibble, tidyr, purrr, broom, pscl)                 # Data frame manipulation 
#install.packages("ggplot2", repos = "http://cran.us.r-project.org", lib = "./libs")
#library(ggplot2, lib.loc = "./libs")
#install.packages("ggthemes", repos = "http://cran.us.r-project.org", lib = "./libs")
#library(ggthemes, lib.loc = "./libs")
#install.packages("dplyr", repos = "http://cran.us.r-project.org", lib = "./libs")
#library(dplyr, lib.loc = "./libs")
#install.packages("tibble", repos = "http://cran.us.r-project.org", lib = "./libs")
#library(tibble, lib.loc = "./libs")
#install.packages("tidyr", repos = "http://cran.us.r-project.org", lib = "./libs")
#library(tidyr, lib.loc = "./libs")
#install.packages("purrr", repos = "http://cran.us.r-project.org", lib = "./libs")
#library(purrr, lib.loc = "./libs")
#install.packages("broom", repos = "http://cran.us.r-project.org", lib = "./libs")
#library(broom, lib.loc = "./libs")
#install.packages("pscl", repos = "http://cran.us.r-project.org", lib = "./libs")
#library(pscl, lib.loc = "./libs")

#-------------------------------------------------------------------------------
OTUs_majority_samples <- function(perc, pre_path) {
    tlevels <- c(
        "Phylum", "Class", "Order", "Family", "Genus"
    )
    for (i in 1:length(tlevels)) {
        db1 <- read.csv(url(paste0(pre_path, tlevels[i], ".csv"))) %>% 
            mutate(X = paste0(X, "_", tlevels[i])) %>%
            rename("ID" = "X")
        if (i == 1) {
            db_all <- db1 %>% 
                filter(!is.character(ID))
        }
        majorityOTUs <- which( rowSums(db1[,-1] > 0) / ncol(db1[,-1]) >= perc / 100 )
        db_all <- db_all %>% 
            full_join(db1[majorityOTUs,], 
                      by = colnames(db1))
    }
    return( db_all )
}

OTUs_majority_samples_taxa <- function(perc, pre_path, taxa) {
    db1 <- read.csv(url(paste0(pre_path, taxa, ".csv"))) %>% 
        mutate(X = paste0(X, "_", taxa)) %>%
        rename("ID" = "X")
    majorityOTUs <- which( rowSums(db1[,-1] > 0) / ncol(db1[,-1]) >= perc / 100 )
    return( db1[majorityOTUs, ] )
}

OTUs_majority_samples_selected <- function(perc, pre_path) {
    db1 <- read.csv(url(paste0(pre_path, "integrated.csv")))
    majorityOTUs <- which( rowSums(db1[,-1] > 0) / ncol(db1[,-1]) >= perc / 100 )
    return( db1[majorityOTUs,] )
}

#-------------------------------------------------------------------------------
initial_path <- ifelse(
    opt$original, 
    "https://raw.githubusercontent.com/ccm-bioinfo/cambda2023/main/02_variable_selection/data/",
    "https://raw.githubusercontent.com/ccm-bioinfo/cambda2023/main/02_variable_selection/selected_variables_results/integrated_tables/"
)

prefix0 <- ifelse(
    opt$reads, "reads", "assembly"
)
prefix1 <- ifelse(
    opt$original, 
    "count", 
    ifelse(opt$all, "", "kingdoms")
)
prefix2 <- ifelse(
    opt$original,
    "",
    opt$model
)
prefix3 <- ifelse(
    opt$original,
    opt$taxa,
    "integrated"
)

path_to_counts <- paste0(
    initial_path, 
    ifelse(
        opt$original, 
        paste0(prefix0, "/"),
        ""
    ),
    prefix0, "_", prefix1, "_", prefix2, "_"
)

if (opt$original) {
    if (opt$taxa == "all") {
        majorOTUs <- OTUs_majority_samples(
            opt$perc, path_to_counts
        )
    } else {
        majorOTUs <- OTUs_majority_samples_taxa(
            opt$perc, path_to_counts, opt$taxa
        )
    }
} else {
    majorOTUs <- OTUs_majority_samples_selected(
        opt$perc, path_to_counts
    )
}

path_to_out <- paste0(
    opt$out_dir, 
    prefix0, "_", 
    ifelse(
        opt$original, 
        ifelse(opt$all, "original_all", paste0("original_", opt$taxa)), 
        paste0("selected_", ifelse(opt$all, "", "kingdoms_"), opt$model)
    ), 
    "_", opt$perc, ".csv"
)

write.csv(x = majorOTUs, file = path_to_out, row.names = FALSE)