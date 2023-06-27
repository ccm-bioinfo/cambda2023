#!/bin/bash 

# Models without separating by kingdoms

# Run Poisson models
# Reads
if [ ! -f "../selected_variables_results/pValues/reads__p_pvalues.csv.gz" ]; then
    Rscript variable_selection.R -m p -O "../selected_variables_results/"
    echo "Done 1"
else 
    echo "Done 1"
fi
# Assembly
if [ ! -f "../selected_variables_results/pValues/assembly__p_pvalues.csv.gz" ]; then
    Rscript variable_selection.R -m p -r FALSE -O "../selected_variables_results/"
    echo "Done 2"
else 
    echo "Done 2"
fi

# Run Negative Binomial models
# Reads
if [ ! -f "../selected_variables_results/pValues/reads__nb_pvalues.csv.gz" ]; then
    Rscript variable_selection.R -m nb -O "../selected_variables_results/"
    echo "Done 3"
else 
    echo "Done 3"
fi
# Assembly
if [ ! -f "../selected_variables_results/pValues/assembly__nb_pvalues.csv.gz" ]; then
    Rscript variable_selection.R -m nb -r FALSE -O "../selected_variables_results/"
    echo "Done 4"
else 
    echo "Done 4"
fi

# Run Zero Inflated Poisson models
# Reads
if [ ! -f "../selected_variables_results/pValues/reads__zip_pvalues.csv.gz" ]; then
    Rscript variable_selection.R -m zip -O "../selected_variables_results/"
    echo "Done 5"
else 
    echo "Done 5"
fi
# Assembly
if [ ! -f "../selected_variables_results/pValues/assembly__zip_pvalues.csv.gz" ]; then
    Rscript variable_selection.R -m zip -r FALSE -O "../selected_variables_results/"
    echo "Done 6"
else 
    echo "Done 6"
fi

# Run Zero Inflated Negative Binomial models
# Reads
if [ ! -f "../selected_variables_results/pValues/reads__zinb_pvalues.csv.gz" ]; then
    Rscript variable_selection.R -m zinb -O "../selected_variables_results/"
    echo "Done 7"
else 
    echo "Done 7"
fi
# Assembly
if [ ! -f "../selected_variables_results/pValues/assembly__zinb_pvalues.csv.gz" ]; then
    Rscript variable_selection.R -m zinb -r FALSE -O "../selected_variables_results/"
    echo "Done 8"
else 
    echo "Done 8"
fi

# Models separating by kingdoms

# Run Poisson models
# Reads
if [ ! -f "../selected_variables_results/pValues/reads_kingdoms_p_pvalues.csv.gz" ]; then
    Rscript variable_selection.R -m p -a FALSE -O "../selected_variables_results/"
    echo "Done 9"
else 
    echo "Done 9"
fi
# Assembly
if [ ! -f "../selected_variables_results/pValues/assembly_kingdoms_p_pvalues.csv.gz" ]; then
    Rscript variable_selection.R -m p -r FALSE -a FALSE -O "../selected_variables_results/"
    echo "Done 10"
else 
    echo "Done 10"
fi

# Run Negative Binomial models
# Reads
if [ ! -f "../selected_variables_results/pValues/reads_kingdoms_nb_pvalues.csv.gz" ]; then
    Rscript variable_selection.R -m nb -a FALSE -O "../selected_variables_results/"
    echo "Done 11"
else 
    echo "Done 11"
fi
# Assembly
if [ ! -f "../selected_variables_results/pValues/assembly_kingdoms_nb_pvalues.csv.gz" ]; then
    Rscript variable_selection.R -m nb -r FALSE -a FALSE -O "../selected_variables_results/"
    echo "Done 12"
else 
    echo "Done 12"
fi

# Run Zero Inflated Poisson models
# Reads
if [ ! -f "../selected_variables_results/pValues/reads_kingdoms_zip_pvalues.csv.gz" ]; then
    Rscript variable_selection.R -m zip -a FALSE -O "../selected_variables_results/"
    echo "Done 13"
else 
    echo "Done 13"
fi
# Assembly
if [ ! -f "../selected_variables_results/pValues/assembly_kingdoms_zip_pvalues.csv.gz" ]; then
    Rscript variable_selection.R -m zip -r FALSE -a FALSE -O "../selected_variables_results/"
    echo "Done 14"
else 
    echo "Done 14"
fi

# Run Zero Inflated Negative Binomial models
# Reads
if [ ! -f "../selected_variables_results/pValues/reads_kingdoms_zinb_pvalues.csv.gz" ]; then
    Rscript variable_selection.R -m zinb -a FALSE -O "../selected_variables_results/"
    echo "Done 15"
else 
    echo "Done 15"
fi
# Assembly
if [ ! -f "../selected_variables_results/pValues/assembly_kingdoms_zinb_pvalues.csv.gz" ]; then
    Rscript variable_selection.R -m zinb -r FALSE -a FALSE -O "../selected_variables_results/"
    echo "Done 16"
else 
    echo "Done 16"
fi
