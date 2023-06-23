library(stringr)


# load the data and avoid the label column

sorted_data <- read.csv("sorted_file_amr.csv") 

matrix_subset <- sorted_data[-366]

#load function 1
# Use str_count function from stringr package to count occurrences

countPatternOccurrences <- function(row, pattern) {
  
  count <- str_count(row, pattern)
  
  # Return the count
  return(count)
}

# load function 2
# count the occurrences of the pattern in the row

  Abundance_AMRs <- function(row,pattern){
  occurrences <- countPatternOccurrences(row, pattern)
  final_vec<- c(pattern,sum(occurrences))
  }

# load function 3  
# calculate abundance by row

Abundance_AMRs_by_row <- function(row){
  unique_values <- c(unique(row))
  lapply(unique_values, function(x) Abundance_AMRs(row,x))
}

# load function 4
# filter abundance by row

top3_abundance<-function(row){

abundance_by_row<-Abundance_AMRs_by_row(row)

numeric_values <- as.numeric(str_extract(abundance_by_row, "\\d+"))

# Sort the list based on the extracted numeric values

sorted_abundance<- abundance_by_row[order(numeric_values, decreasing = TRUE)]

abun_row<-sorted_abundance[1:4]
}

#top3abun<-top3_abundance(row2)

#result <- apply(matrix_subset, 1, top3_abundance)

# main program to create the table
# Apply the function to all rows and create a new column
library(dplyr)

list_top3_abundance <- matrix_subset %>% mutate(new_column = apply(matrix_subset, 1, top3_abundance))

# see the new column

top3columnlist<-list_top3_abundance$new_column


