#!/bin/bash 

# Run the variable selection using a validation data set 
# Negative binomial with separated kingdoms
Rscript variable_selection.R -m nb -a FALSE -O "../selected_variables_results/" -v "../validation_set/train_val.csv"
cd ../selected_variables_results/pValues/
rm reads_kingdoms_nb_pvalues_tv.csv.gz
gzip -9 reads_kingdoms_nb_pvalues_tv.csv
cd ../codes/
