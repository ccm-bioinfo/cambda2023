#-------------------------------------------------------------------------------
# Load libraries via pacman
pacman::p_load(ggplot2, ggthemes,                       # Plots
               dplyr, tibble, tidyr, purrr, broom, pscl)                 # Data frame manipulation 
# library(ggplot2)
# library(ggthemes)
# library(dplyr)
# library(tibble)
# library(purrr)
# library(broom)
# library(pscl)

#-------------------------------------------------------------------------------
# Working directory
# setwd("~/camda/variable_selection/")

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
modelCountsScores <- function(models, method = "AIC") {
    if (method == "AIC") {
        scores <- sapply(models, poss_AIC)
    } else {
        scores <- sapply(models, poss_BIC)
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
modelSelectionCounts <- function(db, formula1, formula2, method = "AIC") {
    # Fit Poisson, Negative Binomial, Zero Inflated Poisson and 
    # Zero Inflated Negative Binomial models
    models <- vector("list", 4)
    models[[1]] <- poss_glm(
        formula = formula1, 
        family = "poisson", 
        data = db
    )
    models[[2]] <- poss_glm.nb(
        formula = formula1, 
        data = db
    )
    models[[3]] <- poss_zinfl(
        formula = formula2, 
        dist = "poisson", 
        data = db
    )
    models[[4]] <- poss_zinfl(
        formula = formula2, 
        dist = "negbin", 
        data = db
    )
    # Compute the scores according to a method (AIC by default)
    scores <- modelCountsScores(models = models, method = method)
    # Select the model with the lowest score
    besto_model <- which.min(scores)
    # Is the model zero inflated?
    zi_mod <- (besto_model > 2)
    # Name explicitly the chosen model
    model_name <- ifelse(
        besto_model < 2, "Poisson", 
        ifelse(
            besto_model < 3, "Negative Binomial", 
            ifelse(
                besto_model < 4, "Zero Inflated Poisson", 
                "Zero Inflated Negative Binomial"
            )
        )
    )
    # Compute the p-value
    pValueModel <- pValueFromSummary(
        fit = models[[besto_model]], 
        zi = zi_mod
    )
    return(
        list(pvalues = pValueModel, model = model_name)
    )
}

#-------------------------------------------------------------------------------
# differentialOtusPvalues calculates the p-values according to log2-fold change 
# for every pair of cities
# This allows us to decide if an OTU is differentially abundant

differentialOtusPvalues <- function(db) {
    #####
    # Getting p-values from the best model
    #
    
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
        loc1 = character(), loc2 = character(), locs = character(), 
        adj_pvalues = double()
    )
    pb <- txtProgressBar(min = 0, max = nLocs * (nLocs - 1) / 2, style = 3)
    k <- 1
    for (i in 1:(nLocs - 1)) {
        for (j in (i+1):nLocs) {
            # Given two city-year classes, we first filter the data that 
            # corresponds to said samples, which we convert to a factor with 
            # levels 0 and 1
            # We then eliminate any OTU that had 0 reads among all the samples 
            # The nesting is done at the OTU level, to fit four models to 
            # count data and obtain a p-value for the best model and said model, 
            # this p-value corresponding to the effect of the city-year variable
            # After unnesting the p-values, we only keep the OTUs ID, their 
            # p-values and the model achieved to get it, 
            # adding for each city-year, a column with the ID of 
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
                    modelSelect = map(data, ~modelSelectionCounts(
                        formula1 = formula(counts ~ offset(logNreads) + sample_loc), 
                        formula2 = formula(counts ~ offset(logNreads) + sample_loc | sample_loc), 
                        db = .
                    ))
                ) %>% 
                unnest_wider(modelSelect) %>% 
                select(c("X", "pvalues", "model")) %>% 
                mutate(
                    loc1 = locations[i], 
                    loc2 = locations[j], 
                    locs = paste0(loc1, "_vs_", loc2)
                ) %>% 
                filter(!is.na(pvalues)) %>% 
                rename("OTU" = "X") %>% 
                mutate(
                    adj_pvalues = p.adjust(pvalues, method = "fdr")
                )
            pValues <- pValues %>% 
                full_join(tempPvalues, by = c(
                    "OTU", "pvalues", "model", "loc1", "loc2", "locs", "adj_pvalues"
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
                                path_to_pvalues = NULL) {
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
    tempPvalues <- differentialOtusPvalues(train_db)
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
        loc1 = character(), loc2 = character(), locs = character(), 
        adj_pvalues = double(),  hlevel = character(), sign_rank = integer()
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
                "OTU", "pvalues", "model", "loc1", "loc2", "locs", 
                "adj_pvalues", "hlevel", "sign_rank"
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
        mutate(ID = paste0(OTU, "_", hlevel)) %>% 
        dplyr::select(-c("OTU", "hlevel")) %>% 
        relocate(ID)
    return(retDF)
}

#-------------------------------------------------------------------------------
# The function variableSelection implements all of the steps to select a subset 
# of OTUs that allow us to differentiate between cities
variableSelection <- function(hlevels = c("_Phylum", "_Class", "_Order", "_Family", "_Genus"), 
                              path_to_counts, train_cols = NULL, kpvalues = 5, reads = TRUE) {
    # Initialize a list to save the matrices of p-values for every run
    pValuesList <- vector("list", length = length(hlevels))
    for (i in 1:length(hlevels)) {
        cat(sprintf("Starting with %s\n", hlevels[i]))
        pValuesList[[i]] <- computePvaluesLevel(
            hLevel = hlevels[i], 
            path_to_counts = path_to_counts, 
            train = train_cols, 
            reads = reads
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
path_to_counts <- "~/camda/variable_selection/reads/"
train_test_set <- read.csv("./Train_Test.csv", row.names = 1)
train_cols <- train_test_set$Num_Col[train_test_set$Train == 1]
kpvalues <- 5
hlevels <- c("_Phylum", #"_Class", "_Order", "_Family", "_Genus", 
             "AB_Phylum", #"AB_Class", "AB_Order", "AB_Family", "AB_Genus", 
             "Eukarya_Phylum", #"Eukarya_Class", "Eukarya_Order", "Eukarya_Family", "Eukarya_Genus",
             "Viruses_Phylum")#, "Viruses_Class", "Viruses_Order", "Viruses_Family", "Viruses_Genus")

smth <- variableSelection(path_to_counts = path_to_counts, 
                          train_cols = train_cols, kpvalues = kpvalues, 
                          hlevels = hlevels)

smth[[1]] %>% 
    ggplot(aes(x = locs, y = -log(adj_pvalues), colour = hlevel)) + 
    geom_hline(yintercept = -log(1e-3), colour = "hotpink") + 
    geom_point(alpha = 0.1, size = 1) + 
    theme_few() + 
    ylab("-log(p-value)") + 
    xlab("") + 
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1, size=rel(0.5)),
          legend.position = "top") + 
    guides(colour = guide_legend(override.aes = list(alpha = 1, size = 4)))

#pValuesPh <- read.csv("./pValues/train_pvalues_Phylum.csv", row.names = 1) %>% 
#    mutate(hlevel = "Phylum")
#pValuesCl <- read.csv("./pValues/train_pvalues_Class.csv", row.names = 1) %>% 
#    mutate(hlevel = "Class")
#pValuesOr <- read.csv("./pValues/train_pvalues_Order.csv", row.names = 1) %>% 
#    mutate(hlevel = "Order")
#pValuesFa <- read.csv("./pValues/train_pvalues_Family.csv", row.names = 1) %>% 
#    mutate(hlevel = "Family")
#pValuesGe <- read.csv("./pValues/train_pvalues_Genus.csv", row.names = 1) %>% 
#    mutate(hlevel = "Genus")

#write.csv(
#    integratedTable, 
#    file = "./integrated_sample.csv",
#    row.names = FALSE
#)
