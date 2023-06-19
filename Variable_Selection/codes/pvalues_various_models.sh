#!/bin/bash 

# Models without separating by kingdoms

# Run Poisson models
# Reads
if [ ! -f "../results/pValues/reads__p_pvalues.csv" ]; then
    Rscript variable_selection.R -m p
fi
# Assembly
if [ ! -f "../results/pValues/assembly__p_pvalues.csv" ]; then
    Rscript variable_selection.R -m p -r FALSE
fi

# Run Negative Binomial models
# Reads
if [ ! -f "../results/pValues/reads__nb_pvalues.csv" ]; then
    Rscript variable_selection.R -m nb
fi
# Assembly
if [ ! -f "../results/pValues/assembly__nb_pvalues.csv" ]; then
    Rscript variable_selection.R -m nb -r FALSE
fi

# Run Zero Inflated Poisson models
# Reads
if [ ! -f "../results/pValues/reads__zip_pvalues.csv" ]; then
    Rscript variable_selection.R -m zip
fi
# Assembly
if [ ! -f "../results/pValues/assembly__zip_pvalues.csv" ]; then
    Rscript variable_selection.R -m zip -r FALSE
fi

# Run Zero Inflated Negative Binomial models
# Reads
if [ ! -f "../results/pValues/reads__zinb_pvalues.csv" ]; then
    Rscript variable_selection.R -m zinb
fi
# Assembly
if [ ! -f "../results/pValues/assembly__zinb_pvalues.csv" ]; then
    Rscript variable_selection.R -m zinb -r FALSE
fi

# Models separating by kingdoms

# Run Poisson models
# Reads
if [ ! -f "../results/pValues/reads_kingdoms_p_pvalues.csv" ]; then
    Rscript variable_selection.R -m p -a FALSE
fi
# Assembly
if [ ! -f "../results/pValues/assembly_kingdoms_p_pvalues.csv" ]; then
    Rscript variable_selection.R -m p -r FALSE -a FALSE
fi

# Run Negative Binomial models
# Reads
if [ ! -f "../results/pValues/reads_kingdoms_nb_pvalues.csv" ]; then
    Rscript variable_selection.R -m nb -a FALSE
fi
# Assembly
if [ ! -f "../results/pValues/assembly_kingdoms_nb_pvalues.csv" ]; then
    Rscript variable_selection.R -m nb -r FALSE -a FALSE
fi

# Run Zero Inflated Poisson models
# Reads
if [ ! -f "../results/pValues/reads_kingdoms_zip_pvalues.csv" ]; then
    Rscript variable_selection.R -m zip -a FALSE
fi
# Assembly
if [ ! -f "../results/pValues/assembly_kingdoms_zip_pvalues.csv" ]; then
    Rscript variable_selection.R -m zip -r FALSE -a FALSE
fi

# Run Zero Inflated Negative Binomial models
# Reads
if [ ! -f "../results/pValues/reads_kingdoms_zinb_pvalues.csv" ]; then
    Rscript variable_selection.R -m zinb -a FALSE
fi
# Assembly
if [ ! -f "../results/pValues/assembly_kingdoms_zinb_pvalues.csv" ]; then
    Rscript variable_selection.R -m zinb -r FALSE -a FALSE
fi
