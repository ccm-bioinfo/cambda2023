#!/usr/bin/env Rscript
library("optparse")

option_list = list(
    make_option(c("-I", "--input_file"), type = "character", 
                default = "https://github.com/ccm-bioinfo/cambda2023/raw/main/06_amr_resistance/data/230701_AMR_mysterious_NCBI_all_nelly.csv", 
                help = "input file [default= %default]", metavar = "character"),
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
               dplyr, tibble, tidyr, purrr, broom, pscl)                 # Data frame manipulation 
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
        filter(City != "mysterious") %>% 
        group_by(ID) %>% 
        mutate(nReads = sum(Presence)) %>% 
        mutate(
            logNreads = ifelse(
                nReads == 0, 1e-30, log(nReads)
                )
            )
    
    # Get all city-year classes and the number of them
    locations <- unique(unlist(db$City))
    nLocs <- length(locations)
    
    # Initialize the data frame where p-values, and adjusted p-values, 
    # will be stored
    # As we will be adjusting a model for each AMR marker, and each pair of 
    # city-year, this IDs will also be stored
    pValues <- data.frame(
        Markers = character(), pvalues = double(),  
        score = double(), loc1 = character(), 
        loc2 = character(), locs = character(), adj_pvalues = double()
    )
    pb <- txtProgressBar(min = 0, max = nLocs * (nLocs - 1) / 2, style = 3)
    k <- 1
    # Construct the formula for the models
    formulaModels <- formula(Presence ~ offset(logNreads) + City)
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
                filter(City %in% locations[c(i, j)]) %>% 
                mutate(City = factor(City)) %>% 
                ungroup() %>% 
                group_by(Markers) %>% 
                mutate(presenceReads = sum(Presence)) %>% 
                ungroup() %>% 
                filter(presenceReads > 0) %>% 
                dplyr::select(-presenceReads) %>%
                nest(-Markers) %>%  
                mutate(
                    modelFit = map(data, ~modelFitting(
                        formula = formulaModels, 
                        db = .
                    ))
                ) %>% 
                unnest_wider(modelFit) %>% 
                dplyr::select(c("Markers", "pvalues", "score")) %>% 
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
                    "Markers", "pvalues", "score", "loc1", "loc2", 
                    "locs", "adj_pvalues"
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
computePvaluesLevel <- function(path_to_counts, path_to_pvalues = NULL) {
    db <- read.csv(url(path_to_counts))
    db <- db %>% 
        pivot_longer(
            -c("ID", "Species", "City", "AST.based.group", "Collection_date", "included"),
            names_to = "Markers", 
            values_to = "Presence"
        )
    # compute p-values
    tempPvalues <- differentialAmrMarkers(db)
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
        Markers = character(), pvalues = double(), 
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
                "Markers", "pvalues", "score", "loc1", "loc2", 
                "locs", "adj_pvalues","sign_rank"
            ))
    }
    
    return(reducedK)
}

#-------------------------------------------------------------------------------
# Given a list of significant AMR markers, construct the reduced sample with only 
# these AMR markers. 
constructReducedData <- function(sign_amr, path_to_counts) {
    db <- read.csv(url(path_to_counts))
    # Subset the identified AMR markers
    retDF <- db %>% 
        dplyr::select(c(
            "ID", "Species", "City", "AST.based.group",  
            unique(unlist(sign_amr[, 1])),
            "Collection_date", "included"
        ))
    return(retDF)
}

#-------------------------------------------------------------------------------
# The function variableSelection implements all of the steps to select a subset 
# of OTUs that allow us to differentiate between cities
variableSelection <- function(path_to_counts, train_cols = NULL, kpvalues = 5) {
    # Compute the p-values
    pValues <- computePvaluesLevel(path_to_counts = path_to_counts)
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
path_to_counts <- opt$input_file
kpvalues <- opt$best_k

smth <- variableSelection(path_to_counts = path_to_counts, 
                          kpvalues = kpvalues)

write.csv(
    smth[[1]],  
    file = paste0(
        opt$out_dir, "pValues_amr/amr_pvalues_010723.csv"
    ),
    row.names = FALSE
)
write.csv(
    smth[[2]],  
    file = paste0(
        opt$out_dir, "significant_amr/amr_signif_010723_adj.csv"
    ),
    row.names = FALSE
)
write.csv(
    smth[[3]], #%>% mutate(`vi tm` = as.character(`vi tm`), 
#                         included = as.character(included)),  
    file = paste0(
        opt$out_dir, "reduced_tables/amr_reduced_010723_adj.csv"
    ),
    row.names = FALSE
)

pplot1 <- smth[[1]] %>% 
    ggplot(aes(x = locs, y = -log(adj_pvalues))) + 
    geom_hline(yintercept = -log(1e-1), colour = "hotpink") + 
    geom_point(alpha = 0.5, size = 1) + 
    theme_few() + 
    ylab("-log(p-value)") + 
    xlab("") + 
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1, size=rel(1)),
          legend.position = "top")

ggsave(
    plot = pplot1, 
    filename = paste0(
        opt$out_dir, "pValues_amr/amr_log_pvalues_010723_adj.png"
    ),
    dpi = 180, width = 12, height = 6.75
)
