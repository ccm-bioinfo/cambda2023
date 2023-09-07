#!/bin/bash 

# Run the variable selection using a validation data set 
# Negative binomial with separated kingdoms

# test for R libraries
echo "Testing for R libraries ====================================================="

# start the script
echo "Running the variable selection with a train data set ========================"
Rscript Scripts/Variable_selection.R -m nb -a FALSE -O "../selected_variables_results/" -v "Data/train_val.csv"
echo "preparing the results ======================================================="
cd ../selected_variables_results/pValues/
rm reads_kingdoms_nb_pvalues_tv.csv.gz
gzip -9 reads_kingdoms_nb_pvalues_tv.csv
cd ../codes/
