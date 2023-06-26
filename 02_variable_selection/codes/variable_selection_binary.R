#!/usr/bin/env Rscript
library("optparse")

option_list = list(
    make_option(c("-I", "--input_dir"), type = "character", 
                default = "../../01_preprocessing/amr/", 
                help = "input directory [default= %default]", metavar = "character"),
    make_option(c("-O", "--out_dir"), type = "character", 
                default = "../selected_variables_results/", 
                help = "output directory [default= %default]", metavar = "character"),
    make_option(c("-k", "--best_k"), type = "integer", default = 5, 
                help = "number of significant AMR markers", metavar = "integer"),
    make_option(c("-v", "--validation"), type = "character", default = NULL, 
                help = "path to a file which specifies the validation samples",
                metavar = "character")
); 

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

# 25 june 2023
# Imanol Nuñez

#-------------------------------------------------------------------------------
# Load libraries via pacman
pacman::p_load(ggplot2, ggthemes,                       # Plots
               dplyr, tibble, tidyr, purrr, broom, pscl, data.table)                 # Data frame manipulation 
# library(ggplot2)
# library(ggthemes)
# library(dplyr)
# library(tibble)
# library(tidyr)
# library(purrr)
# library(broom)
# library(pscl)

#-------------------------------------------------------------------------------
# Safety functions to keep differentialAmrMarkers running even if certain 
# fits cannot be achieved by numerical errors
poss_glm <- possibly(.f = glm, otherwise = NULL)
poss_glm.nb <- possibly(.f = MASS::glm.nb, otherwise = NULL)
poss_zinfl <- possibly(.f = pscl::zeroinfl, otherwise = NULL)
poss_AIC <- possibly(.f = AIC, otherwise = Inf)
poss_BIC <- possibly(.f = BIC, otherwise = Inf)

#-------------------------------------------------------------------------------
# Compute the AIC score for a list of models
modelCountsScore <- function(models, method = "AIC") {
    if (method == "AIC") {
        scores <- poss_AIC(models)
    } else {
        scores <- poss_BIC(models)
    } 
    return(scores)
}

#-------------------------------------------------------------------------------
# Extract the p-value for a non-constant term in a regression model of the 
# form y ~ 1 + x
pValueFromSummary <- function(fit) {
    if (is.null(fit)) {
        pValue <- NA
    } else {
        pValue <- summary(fit)$coefficients[,4][2]
    }
    return(pValue)
}

#-------------------------------------------------------------------------------
# Select the best model for the presence/absence of an AMR marker
# and return the associated p-value and name of the selected model
modelFitting <- function(db, formula, method = "AIC") {
    # Fit logistic regression
    modelFit <- poss_glm(
        formula = formula, 
        family = binomial(link = "logit"), 
        data = db
    )
    # Compute the scores according to a method (AIC by default)
    scores <- modelCountsScore(models = modelFit, method = method)
    # Compute the p-value
    pValueModel <- pValueFromSummary(
        fit = modelFit
    )
    return(
        list(pvalues = pValueModel, score = scores)
    )
}

#-------------------------------------------------------------------------------
# differentialAmrMarkers calculates the p-values according to log2-fold change 
# for every pair of cities
# This allows us to decide if an AMR marker is differentially abundant

differentialAmrMarkers <- function(db) {
    #####
    # Get pvalues fitting a count model to db
    
    # We assume that the data is given by columns, where the first two columns 
    # corresponds to the AMR marker and its ARO ID, and the others to the samples
    # We pivot the data to a longer table with four columns: the AMR marker, the 
    # ARO ID, the sample name and the number of reads of an OTU in an sample
    # Then we add a column with the number of reads for each sample and a 
    # logarithmic transformation
    # We finally add the city and year from where the sample is from
    db <- db %>% 
        as_tibble() %>% 
        pivot_longer(-c("V1", "aro"), names_to = "sample", values_to = "presence") %>% 
        group_by(sample) %>% 
        mutate(nReads = sum(presence)) %>% 
        mutate(
            logNreads = ifelse(
                nReads == 0, 1e-30, log(nReads)
            ), 
            city = substr(sample, 24, 26), 
            year = substr(sample, 21, 22), 
            sample_loc = paste0(city, year))
    
    # Get all city-year classes and the number of them
    locations <- unique(unlist(db$sample_loc))
    nLocs <- length(locations)
    
    # Initialize the data frame where p-values, and adjusted p-values, 
    # will be stored
    # As we will be adjusting a model for each AMR marker, and each pair of 
    # city-year, this IDs will also be stored
    pValues <- data.frame(
        V1 = character(), aro = integer(), pvalues = double(),  
        score = double(), loc1 = character(), 
        loc2 = character(), locs = character(), adj_pvalues = double()
    )
    pb <- txtProgressBar(min = 0, max = nLocs * (nLocs - 1) / 2, style = 3)
    k <- 1
    # Construct the formula for the models
    formulaModels <- formula(presence ~ offset(logNreads) + sample_loc)
    for (i in 1:(nLocs - 1)) {
        for (j in (i+1):nLocs) {
            # Given two city-year classes, we first filter the data that 
            # corresponds to said samples, which we convert to a factor with 
            # levels 0 and 1
            # We then eliminate any AMR marker that had 0 reads among all the sample 
            # The nesting is done at the AMR marker level, to adjust a negative 
            # binomial model for each AMR marker
            # After the models are adjsuted, we extract the p-value of the 
            # coefficient corresponding to the dummy variable given by the 
            # city-year
            # After unnesting the p-values, we only keep the AMR markers and IDs and their 
            # p-values, adding for each city-year, a column with the ID of 
            # city-years being compared
            # We then filter any AMR markers such that the computed p-value is NA, 
            # to then compute the adjusted p-values via the Benjamini-Hochberg
            # correction
            tempPvalues <- db %>% 
                filter(sample_loc %in% locations[c(i, j)]) %>% 
                mutate(sample_loc = factor(sample_loc)) %>% 
                ungroup() %>% 
                group_by(V1, aro) %>% 
                mutate(presenceReads = sum(presence)) %>% 
                ungroup() %>% 
                filter(presenceReads > 0) %>% 
                select(-presenceReads) %>%
                nest(-c(V1, aro)) %>%  
                mutate(
                    modelFit = map(data, ~modelFitting(
                        formula = formulaModels, 
                        db = .
                    ))
                ) %>% 
                unnest_wider(modelFit) %>% 
            select(c("V1", "aro", "pvalues", "score")) %>% 
                mutate(
                    loc1 = locations[i], 
                    loc2 = locations[j], 
                    locs = paste0(loc1, "_vs_", loc2)
                ) %>% 
                filter(!is.na(pvalues)) %>% 
                filter(is.finite(score)) %>% 
                mutate(
                    adj_pvalues = p.adjust(pvalues, method = "fdr")
                )
            # We join the computed p-values to the data.frame that contains 
            # the computed p-values in previos iterations
            pValues <- pValues %>% 
                full_join(tempPvalues, by = c(
                    "V1", "aro", "pvalues", "score", "loc1", "loc2", "locs", "adj_pvalues"
                ))
            setTxtProgressBar(pb, k)
            k <- k + 1
        }
    }
    
    return(pValues)
}

#-------------------------------------------------------------------------------
# computePvaluesLevel computes a matrix of p-values for the negative binomial 
# model adjusted by differentialAmrMarkers for the presence data
# This function may take into account a set of indices for training 
computePvaluesLevel <- function(path_to_counts, train = NULL, 
                                path_to_pvalues = NULL) {
    db <- as.data.frame(fread(
        paste0(path_to_counts, "amr-presence.tsv")
    ))
    # Subsetting training data set
    if (is.null(train)) {
        train_db <- db
    } else {
        train_db <- db[, train]
    }
    # compute p-values
    tempPvalues <- differentialAmrMarkers(train_db)
    return(tempPvalues)
}

#-------------------------------------------------------------------------------
# Given a table of p-values, getKAmrMarkers gets the k most significant AMR markers 
# for each pair of city/year, specifying the hierarchical level of said AMR markers
getKAmrMarkers <- function(db, k) {
    # Which comparisons were made
    comparisons <- unique(unlist(db$locs))
    # Initialize the data frame for the k most significant OTUs per 
    # city vs city contrast
    reducedK <- data.frame(
        V1 = character(), aro = integer(), pvalues = double(), 
        score = double(), loc1 = character(), 
        loc2 = character(), locs = character(), adj_pvalues = double(),  
        sign_rank = integer()
    )
    # Get the significant AMR markers
    for(i in 1:length(comparisons)) {
        tempData <- db %>% 
            filter(locs == comparisons[i]) %>% 
            arrange(adj_pvalues) %>% 
            head(n = k) %>% 
            mutate(sign_rank = 1:k)
        reducedK <- reducedK %>% 
            full_join(tempData, by = c(
                "V1", "aro", "pvalues", "score", "loc1", "loc2", "locs", "adj_pvalues",
                "sign_rank"
            ))
    }

    return(reducedK)
}

#-------------------------------------------------------------------------------
# Given a list of significant AMR markers, construct the reduced sample with only 
# these AMR markers. 
constructReducedData <- function(sign_amr, path_to_counts) {
    db <- as.data.frame(fread(
        paste0(path_to_counts, "amr-presence.tsv")
    ))
    # Subset the identified AMR markers
    retDF <- db[db[, 1] %in% unlist(sign_amr[, 1]), ]
    return(retDF)
}

#-------------------------------------------------------------------------------
# The function variableSelection implements all of the steps to select a subset 
# of OTUs that allow us to differentiate between cities
variableSelection <- function(path_to_counts, train_cols = NULL, kpvalues = 5) {
    # Compute the p-values
    pValues <- computePvaluesLevel(path_to_counts = path_to_counts, 
                                   train = train_cols)
    # Merge all of the p-values matrices
    # Given the complete list of p-values, get the k most significant for every 
    # pair of cities
    significantAMR <- getKAmrMarkers(pValues, kpvalues)
    # Construct the integrated data with the significant OTUs 
    reducedTable <- constructReducedData(significantAMR, path_to_counts)
    return(list(pValues, significantAMR, reducedTable))
}

#-------------------------------------------------------------------------------
# Test
prefix0 <- "amr"
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
kpvalues <- opt$best_k

smth <- variableSelection(path_to_counts = path_to_counts, 
                          train_cols = train_cols, kpvalues = kpvalues)

write.csv(
    smth[[1]],  
    file = paste0(
        opt$out_dir, "pValues_amr/amr_pvalues", suffix0,".csv"
    ),
    row.names = FALSE
)
write.csv(
    smth[[2]],  
    file = paste0(
        opt$out_dir, "significant_amr/amr_signif", suffix0,".csv"
    ),
    row.names = FALSE
)
write.csv(
    smth[[3]],  
    file = paste0(
        opt$out_dir, "reduced_tables/amr_reduced", suffix0,".csv"
    ),
    row.names = FALSE
)

pplot1 <- smth[[1]] %>% 
    ggplot(aes(x = locs, y = -log(adj_pvalues))) + 
    geom_hline(yintercept = -log(1e-3), colour = "hotpink") + 
    geom_point(alpha = 0.5, size = 1) + 
    theme_few() + 
    ylab("-log(p-value)") + 
    xlab("") + 
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1, size=rel(0.5)),
          legend.position = "top")

ggsave(
    plot = pplot1, 
    filename = paste0(
    opt$out_dir, "pValues_amr/amr_log_pvalues", suffix0,".png"
    ),
    dpi = 180, width = 12, height = 6.75
)
