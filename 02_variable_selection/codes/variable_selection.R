#!/usr/bin/env Rscript
library("optparse")

option_list = list(
    make_option(c("-I", "--input_dir"), type = "character", default = "../data/", 
                help = "input directory [default= %default]", metavar = "character"),
    make_option(c("-O", "--out_dir"), type = "character", default = "../results/", 
                help = "output directory [default= %default]", metavar = "character"),
    make_option(c("-r", "--reads"), type = "logical", default = TRUE,
                help = "reads (TRUE) or assembly (FALSE) [default= %default]", 
                metavar = "logical"),
    make_option(c("-a", "--all"), type = "logical", default = TRUE, 
                help = "run with all (TRUE) kingdoms or separated (FALSE) by AB, Eu & Vi",
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

# 19 june 2023
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
# Safety functions to keep differentialOtusPvalues running even if certain 
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
# form y ~ 1 + x if it is not zero inflated, and a regression of the form 
# y ~ (1 + x | x) if a model is zero inflated
pValueFromSummary <- function(fit, zi = FALSE) {
    if (is.null(fit)) {
        pValue <- NA
    } else {
        if (zi) {
            pValue <- summary(fit)$coefficients$count[,4][2]
        } else {
            pValue <- summary(fit)$coefficients[,4][2]
        }
    }
    return(pValue)
}

#-------------------------------------------------------------------------------
# Select the best model for the counts of an OTU
# and return the associated p-value and name of the selected model
modelFitting <- function(db, formula, model, method = "AIC") {
    # Fit Poisson, Negative Binomial, Zero Inflated Poisson and 
    # Zero Inflated Negative Binomial models
    if (model == "p") {
        modelFit <- poss_glm(
            formula = formula, 
            family = "poisson", 
            data = db
        )
        zi_mod <- FALSE
    } else if (model == "nb") {
        modelFit <- poss_glm.nb(
            formula = formula, 
            data = db
        )
        zi_mod <- FALSE
    } else if (model == "zip") {
        modelFit <- poss_zinfl(
            formula = formula, 
            dist = "poisson", 
            data = db
        )
        zi_mod <- TRUE
    } else if (model == "zinb") {
        modelFit <- poss_zinfl(
            formula = formula, 
            dist = "negbin", 
            data = db
        )
        zi_mod <- TRUE
    }
    # Compute the scores according to a method (AIC by default)
    scores <- modelCountsScore(models = modelFit, method = method)
    # Compute the p-value
    pValueModel <- pValueFromSummary(
        fit = modelFit, 
        zi = zi_mod
    )
    return(
        list(pvalues = pValueModel, model = model, score = scores)
    )
}

#-------------------------------------------------------------------------------
# differentialOtusPvalues calculates the p-values according to log2-fold change 
# for every pair of cities
# This allows us to decide if an OTU is differentially abundant
# This only works correctly at all hierarchical levels for reads 

differentialOtusPvalues <- function(db, model) {
    #####
    # Get pvalues fitting a count model to db
    
    # We assume that the data is given by columns, where the first column 
    # corresponds to the OTU ID and the others to the samples
    # We pivot the data to a longer table with three columns: the OTUS, the 
    # sample name and the number of reads of an OTU in an sample
    # Then we add a column with the number of reads for each sample and a 
    # logarithmic transformation
    # We finally add the city and year from where the sample is from
    db <- db %>% 
        as_tibble() %>% 
        pivot_longer(-"X", names_to = "sample", values_to = "counts") %>% 
        group_by(sample) %>% 
        mutate(nReads = sum(counts)) %>% 
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
    # As we will be adjusting a model for each OTU, and each pair of 
    # city-year, this IDs will also be stored
    pValues <- data.frame(
        OTU = integer(), pvalues = double(), model = character(), 
        score = double(), loc1 = character(), 
        loc2 = character(), locs = character(), adj_pvalues = double()
    )
    pb <- txtProgressBar(min = 0, max = nLocs * (nLocs - 1) / 2, style = 3)
    k <- 1
    # Construct the formula for the models
    if (model %in% c("zip", "zinb")) {
        formulaModels <- formula(counts ~ offset(logNreads) + sample_loc | sample_loc)
    } else {
        formulaModels <- formula(counts ~ offset(logNreads) + sample_loc)
    }
    for (i in 1:(nLocs - 1)) {
        for (j in (i+1):nLocs) {
            # Given two city-year classes, we first filter the data that 
            # corresponds to said samples, which we convert to a factor with 
            # levels 0 and 1
            # We then eliminate any OTU that had 0 reads among all the sample 
            # The nesting is done at the OTU level, to adjust a negative 
            # binomial model for each OTU
            # After the models are adjsuted, we extract the p-value of the 
            # coefficient corresponding to the dummy variable given by the 
            # city-year
            # After unnesting the p-values, we only keep the OTUs ID and their 
            # p-values, adding for each city-year, a column with the ID of 
            # city-years being compared
            # We then filter any OTUs such that the computed p-value is NA, 
            # to then compute the adjusted p-values via the Benjamini-Hochberg
            # correction
            tempPvalues <- db %>% 
                filter(sample_loc %in% locations[c(i, j)]) %>% 
                mutate(sample_loc = factor(sample_loc)) %>% 
                ungroup() %>% group_by(X) %>% 
                mutate(otuReads = sum(counts)) %>% 
                ungroup() %>% 
                filter(otuReads > 0) %>% 
                select(-otuReads) %>%
                nest(-X) %>%  
                mutate(
                    modelFit = map(data, ~modelFitting(
                        formula = formulaModels, 
                        model = model, 
                        db = .
                    ))
                ) %>% 
                unnest_wider(modelFit) %>% 
                select(c("X", "pvalues", "model", "score")) %>% 
                mutate(
                    loc1 = locations[i], 
                    loc2 = locations[j], 
                    locs = paste0(loc1, "_vs_", loc2)
                ) %>% 
                filter(!is.na(pvalues)) %>% 
                filter(is.finite(score)) %>% 
                rename("OTU" = "X") %>% 
                mutate(
                    adj_pvalues = p.adjust(pvalues, method = "fdr")
                )
            # We join the computed p-values to the data.frame that contains 
            # the computed p-values in previos iterations
            pValues <- pValues %>% 
                full_join(tempPvalues, by = c(
                    "OTU", "pvalues", "model", "score", "loc1", "loc2", "locs", "adj_pvalues"
                ))
            setTxtProgressBar(pb, k)
            k <- k + 1
        }
    }
    
    return(pValues)
}

#-------------------------------------------------------------------------------
# computePvaluesLevel computes a matrix of p-values for the negative binomial 
# model adjusted by differentialOtusPvalues for the count data of 
# reads for the hierarchical level hLevel
# This function may take into account a set of indices for training 
computePvaluesLevel <- function(hLevel, path_to_counts, reads = TRUE, train = NULL, 
                                path_to_pvalues = NULL, model = "nb") {
    # Test if the count data is for reads or for assembly data
    if (reads) {
        db <- read.csv(paste0(path_to_counts, "reads", 
                              sub('(.*)_.*', '\\1', hLevel, perl = TRUE), 
                              "_count__",
                              sub('.*_(.*)', '\\1', hLevel, perl = TRUE), ".csv"))
    } else {
        db <- read.csv(paste0(path_to_counts, "assembly", 
                              sub('(.*)_.*', '\\1', hLevel, perl = TRUE), 
                              "_count__",
                              sub('.*_(.*)', '\\1', hLevel, perl = TRUE), ".csv"))
    }
    # Subsetting training data set
    if (is.null(train)) {
        train_db <- db
    } else {
        train_db <- db[, train]
    }
    # compute p-values
    tempPvalues <- differentialOtusPvalues(train_db, model)
    # Save p-values for further exploratory analysis
    #write.csv(
    #    tempPvalues, 
    #    file = paste0(path_to_pvalues, "train_pvalues_", hLevel, ".csv"), 
    #    row.names = FALSE
    #)
    # Add the level of the p_value
    tempPvalues <- tempPvalues %>% mutate(hlevel = hLevel)
    return(tempPvalues)
}

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
# The function variableSelection implements all of the steps to select a subset 
# of OTUs that allow us to differentiate between cities
variableSelection <- function(hlevels = c("_Phylum", "_Class", "_Order", "_Family", "_Genus"), 
                              path_to_counts, train_cols = NULL, kpvalues = 5, reads = TRUE, 
                              model = "nb") {
    # Initialize a list to save the matrices of p-values for every run
    pValuesList <- vector("list", length = length(hlevels))
    for (i in 1:length(hlevels)) {
        cat(sprintf("Starting with %s\n", hlevels[i]))
        pValuesList[[i]] <- computePvaluesLevel(
            hLevel = hlevels[i], 
            path_to_counts = path_to_counts, 
            train = train_cols, 
            reads = reads,
            model = model
        )
        cat(sprintf("\n%d of %d done\n", i, length(hlevels)))
    }
    # Merge all of the p-values matrices
    pValues <- pValuesList[[1]]
    if (length(hlevels) > 1) {
        for (i in 2:length(hlevels)) {
            pValues <- pValues %>% 
                full_join(pValuesList[[i]])
        }
    }
    # Given the complete list of p-values, get the k most significant for every 
    # pair of cities
    significantOtus <- getKOtus(pValues, kpvalues)
    # Construct the integrated data with the significant OTUs 
    integratedTable <- constructIntegratedData(significantOtus,
                                               path_to_counts,
                                               reads)
    return(list(pValues, significantOtus, integratedTable))
}

#-------------------------------------------------------------------------------
# Test
prefix0 <- ifelse(opt$reads, "reads", "assembly")
prefix1 <- ifelse(opt$all, "", "kingdoms")
path_to_counts <- paste0(opt$input_dir, prefix0, "/")
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
# train_test_set <- read.csv("./Train_Test.csv", row.names = 1)
# train_cols <- train_test_set$Num_Col[train_test_set$Train == 1]
kpvalues <- opt$best_k
if (opt$all) {
    hlevels <- c("_Phylum", "_Class", "_Order", "_Family", "_Genus")
} else {
    hlevels <- c(
        "AB_Phylum", "AB_Class", "AB_Order", "AB_Family", "AB_Genus",
        "Eukarya_Phylum", "Eukarya_Class", "Eukarya_Order", "Eukarya_Family", "Eukarya_Genus",
        "Viruses_Phylum", "Viruses_Class", "Viruses_Order", "Viruses_Family", "Viruses_Genus"
    )
}

smth <- variableSelection(path_to_counts = path_to_counts, 
                          train_cols = train_cols, kpvalues = kpvalues, 
                          hlevels = hlevels, model = opt$model,
                          reads = opt$reads)

write.csv(
    smth[[1]],  
    file = paste0(
        opt$out_dir, "pValues/", prefix0, "_", prefix1, "_", opt$model, "_", "pvalues",
        suffix0, ".csv"
    ),
    row.names = FALSE
)
write.csv(
    smth[[2]],  
    file = paste0(
        opt$out_dir, "significant_otus/", prefix0, "_", prefix1, "_", opt$model, "_", 
        "signif", suffix0,".csv"
    ),
    row.names = FALSE
)
write.csv(
    smth[[3]],  
    file = paste0(
        opt$out_dir, "integrated_tables/", prefix0, "_", prefix1, "_", opt$model, "_", 
        "integrated", suffix0,".csv"
    ),
    row.names = FALSE
)

pplot1 <- smth[[1]] %>% 
    ggplot(aes(x = locs, y = -log(adj_pvalues), colour = hlevel)) + 
    geom_hline(yintercept = -log(1e-3), colour = "hotpink") + 
    geom_point(alpha = 0.5, size = 1) + 
    theme_few() + 
    ylab("-log(p-value)") + 
    xlab("") + 
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1, size=rel(0.5)),
          legend.position = "top") + 
    guides(colour = guide_legend(override.aes = list(alpha = 1, size = 4)))

ggsave(
    plot = pplot1, 
    filename = paste0(
        opt$out_dir, "pValues/", prefix0, "_", prefix1, "_", opt$model, "_", 
        "log_pvalues", suffix0,".png"
    ),
    dpi = 180, width = 12, height = 6.75
)
