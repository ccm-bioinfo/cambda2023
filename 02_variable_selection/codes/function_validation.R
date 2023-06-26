# 25 june 2023
# Imanol Nuñez
# 6 june 2023
# Mario Carranza

#-------------------------------------------------------------------------------
# Load libraries via pacman
pacman::p_load(ggplot2, dplyr, tidyverse, tibble, tidyr)

#-------------------------------------------------------------------------------
# Function to get a subset of training/test and a subset for validation
training_test <- function(db, perc = 0.3){
    # Number of samples in db
    auxVect <- 2:dim(db)[2]
    
    # Get the city and year of the samples
    DF <- db %>% 
        pivot_longer(cols = auxVect) %>%
        mutate(ID_sample = as.numeric(factor(name))) %>% 
        mutate(name_2 = name) %>% 
        separate(name_2, sep = "_", 
                 into = c("Cambda", "Metasub", "year", "city", "rep")) %>% 
        rename(OTU = "X") %>% 
        mutate(OTU = factor(OTU)) %>% 
        mutate(abs_value = value) %>% 
        group_by(ID_sample) %>%  
        mutate(value = value / sum(value)) %>% 
        mutate(year_city = paste0(year, "_", city)) 
        
    # Unique city-years
    Nombres <- DF$year_city %>% 
        unique()
    # Sample probabilities. The most frequent city-years get higher probability
    Probs <- unique(DF[, c("ID_sample", "year_city")]) %>% 
        .[, c(2)] %>% 
        table() 
    PP <- Probs / sum(Probs)
    
    # Size of the sample for validation, according to perc
    sSize <- round(perc * length(auxVect))
    # Samples that will be in the validation dataset
    Muestra1 <- sample(Nombres, size = sSize, replace = TRUE, prob = PP) %>% 
        sort()
    
    # ??? Not sure what is the function of this line
    Padron <- unique(DF[, c("ID_sample", "year_city")])
    
    # Getting the samples for the validation data set for each city-year (?)
    MM <- c()
    for (e in unique(Muestra1)) {
        XX <- Padron %>% 
            filter(year_city == e) %>% 
            dplyr::select(ID_sample) %>% 
            as.data.frame() %>% 
            .[,1]
        MM <- c(MM, sample(x = XX, size = sum(Muestra1 == e), replace = FALSE))
    }
    
    # Creating a table with the column numbers, names, and two columns that 
    # specify if a column will be used as validation or not
    Nom_Col <- integrated_sample[,] %>% 
        names()
    Num_Col <- 1:length(Nom_Col)
    Train <- rep(1, length(Nom_Col))
    Train[unlist(c(Padron[MM, 1])) + 1] <- 0
    Test <- rep(0, length(Nom_Col))
    Test[unlist(c(Padron[MM, 1])) + 1] <- 1
    Test[1] <- 1
    Train_Test <- tibble(Num_Col, Nom_Col, Train, Test)
    return(Train_Test)
}

#-------------------------------------------------------------------------------
# Construction a train/test and validation partition
countsPhylum <- read_csv("../data/reads/reads_count__Phylum.csv")

train_val <- training_test(countsPhylum) %>% 
    rename(Validation = Test)

write.csv(
    train_val,
    file = "../validation_set/train_val.csv",
    row.names = FALSE
)
