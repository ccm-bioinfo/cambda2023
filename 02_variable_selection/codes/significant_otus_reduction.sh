#!/bin/bash

# Construct the significant OTUs table that differentiate NYC from other USA cities (?)

# From reads data
# Poisson
if [ ! -f "../selected_variables_results/reduced_significant_otus/reads__p_signif_reduced.csv" ]; then
    Rscript significant_otu_unnesting.R -m p
fi
# Negative binomial
if [ ! -f "../selected_variables_results/reduced_significant_otus/reads__nb_signif_reduced.csv" ]; then
    Rscript significant_otu_unnesting.R -m nb
fi
# Zero inflated Poisson
if [ ! -f "../selected_variables_results/reduced_significant_otus/reads__zip_signif_reduced.csv" ]; then
    Rscript significant_otu_unnesting.R -m zip
fi
# Zero inflated negative binomial
if [ ! -f "../selected_variables_results/reduced_significant_otus/reads__zinb_signif_reduced.csv" ]; then
    Rscript significant_otu_unnesting.R -m zinb
fi
# With model selection
if [ ! -f "../selected_variables_results/reduced_significant_otus/reads__best_signif_reduced.csv" ]; then
    Rscript significant_otu_unnesting.R -m best
fi

# Poisson
if [ ! -f "../selected_variables_results/reduced_significant_otus/reads_kingdoms_p_signif_reduced.csv" ]; then
    Rscript significant_otu_unnesting.R -m p -a FALSE
fi
# Negative binomial
if [ ! -f "../selected_variables_results/reduced_significant_otus/reads_kingdoms_nb_signif_reduced.csv" ]; then
    Rscript significant_otu_unnesting.R -m nb -a FALSE
fi
# Zero inflated Poisson
if [ ! -f "../selected_variables_results/reduced_significant_otus/reads_kingdoms_zip_signif_reduced.csv" ]; then
    Rscript significant_otu_unnesting.R -m zip -a FALSE
fi
# Zero inflated negative binomial
if [ ! -f "../selected_variables_results/reduced_significant_otus/reads_kingdoms_zinb_signif_reduced.csv" ]; then
    Rscript significant_otu_unnesting.R -m zinb -a FALSE
fi
# With model selection
if [ ! -f "../selected_variables_results/reduced_significant_otus/reads_kingdoms_best_signif_reduced.csv" ]; then
    Rscript significant_otu_unnesting.R -m best -a FALSE
fi

# From assembly data
# Poisson
if [ ! -f "../selected_variables_results/reduced_significant_otus/assembly__p_signif_reduced.csv" ]; then
    Rscript significant_otu_unnesting.R -m p -r FALSE
fi
# Negative binomial
if [ ! -f "../selected_variables_results/reduced_significant_otus/assembly__nb_signif_reduced.csv" ]; then
    Rscript significant_otu_unnesting.R -m nb -r FALSE
fi
# Zero inflated Poisson
if [ ! -f "../selected_variables_results/reduced_significant_otus/assembly__zip_signif_reduced.csv" ]; then
    Rscript significant_otu_unnesting.R -m zip -r FALSE
fi
# Zero inflated negative binomial
if [ ! -f "../selected_variables_results/reduced_significant_otus/assembly__zinb_signif_reduced.csv" ]; then
    Rscript significant_otu_unnesting.R -m zinb -r FALSE
fi
# With model selection
if [ ! -f "../selected_variables_results/reduced_significant_otus/assembly__best_signif_reduced.csv" ]; then
    Rscript significant_otu_unnesting.R -m best -r FALSE
fi

# Poisson
if [ ! -f "../selected_variables_results/reduced_significant_otus/assembly_kingdoms_p_signif_reduced.csv" ]; then
    Rscript significant_otu_unnesting.R -m p -a FALSE -r FALSE
fi
# Negative binomial
if [ ! -f "../selected_variables_results/reduced_significant_otus/assembly_kingdoms_nb_signif_reduced.csv" ]; then
    Rscript significant_otu_unnesting.R -m nb -a FALSE -r FALSE
fi
# Zero inflated Poisson
if [ ! -f "../selected_variables_results/reduced_significant_otus/assembly_kingdoms_zip_signif_reduced.csv" ]; then
    Rscript significant_otu_unnesting.R -m zip -a FALSE -r FALSE
fi
# Zero inflated negative binomial
if [ ! -f "../selected_variables_results/reduced_significant_otus/assembly_kingdoms_zinb_signif_reduced.csv" ]; then
    Rscript significant_otu_unnesting.R -m zinb -a FALSE -r FALSE
fi
# With model selection
if [ ! -f "../selected_variables_results/reduced_significant_otus/assembly_kingdoms_best_signif_reduced.csv" ]; then
    Rscript significant_otu_unnesting.R -m best -a FALSE -r FALSE
fi

