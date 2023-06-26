#!/bin/bash

# Construct the significant OTUs table that differentiate NYC from other USA cities (?)

# From reads data
# Poisson
if [ ! -f "../selected_variables_results/nyc_otus_list/nyc_otus_reads__p.csv" ]; then
    Rscript sign_otus_nyc.R -m p
fi
# Negative binomial
if [ ! -f "../selected_variables_results/nyc_otus_list/nyc_otus_reads__nb.csv" ]; then
    Rscript sign_otus_nyc.R -m nb
fi
# Zero inflated Poisson
if [ ! -f "../selected_variables_results/nyc_otus_list/nyc_otus_reads__zip.csv" ]; then
    Rscript sign_otus_nyc.R -m zip
fi
# Zero inflated negative binomial
if [ ! -f "../selected_variables_results/nyc_otus_list/nyc_otus_reads__zinb.csv" ]; then
    Rscript sign_otus_nyc.R -m zinb
fi
# With model selection
if [ ! -f "../selected_variables_results/nyc_otus_list/nyc_otus_reads__best.csv" ]; then
    Rscript sign_otus_nyc.R -m best
fi

# Poisson
if [ ! -f "../selected_variables_results/nyc_otus_list/nyc_otus_reads_kingdoms_p.csv" ]; then
    Rscript sign_otus_nyc.R -m p -a FALSE
fi
# Negative binomial
if [ ! -f "../selected_variables_results/nyc_otus_list/nyc_otus_reads_kingdoms_nb.csv" ]; then
    Rscript sign_otus_nyc.R -m nb -a FALSE
fi
# Zero inflated Poisson
if [ ! -f "../selected_variables_results/nyc_otus_list/nyc_otus_reads_kingdoms_zip.csv" ]; then
    Rscript sign_otus_nyc.R -m zip -a FALSE
fi
# Zero inflated negative binomial
if [ ! -f "../selected_variables_results/nyc_otus_list/nyc_otus_reads_kingdoms_zinb.csv" ]; then
    Rscript sign_otus_nyc.R -m zinb -a FALSE
fi
# With model selection
if [ ! -f "../selected_variables_results/nyc_otus_list/nyc_otus_reads_kingdoms_best.csv" ]; then
    Rscript sign_otus_nyc.R -m best -a FALSE
fi

# From assembly data
# Poisson
if [ ! -f "../selected_variables_results/nyc_otus_list/nyc_otus_assembly__p.csv" ]; then
    Rscript sign_otus_nyc.R -m p -r FALSE
fi
# Negative binomial
if [ ! -f "../selected_variables_results/nyc_otus_list/nyc_otus_assembly__nb.csv" ]; then
    Rscript sign_otus_nyc.R -m nb -r FALSE
fi
# Zero inflated Poisson
if [ ! -f "../selected_variables_results/nyc_otus_list/nyc_otus_assembly__zip.csv" ]; then
    Rscript sign_otus_nyc.R -m zip -r FALSE
fi
# Zero inflated negative binomial
if [ ! -f "../selected_variables_results/nyc_otus_list/nyc_otus_assembly__zinb.csv" ]; then
    Rscript sign_otus_nyc.R -m zinb -r FALSE
fi
# With model selection
if [ ! -f "../selected_variables_results/nyc_otus_list/nyc_otus_assembly__best.csv" ]; then
    Rscript sign_otus_nyc.R -m best -r FALSE
fi

# Poisson
if [ ! -f "../selected_variables_results/nyc_otus_list/nyc_otus_assembly_kingdoms_p.csv" ]; then
    Rscript sign_otus_nyc.R -m p -a FALSE -r FALSE
fi
# Negative binomial
if [ ! -f "../selected_variables_results/nyc_otus_list/nyc_otus_assembly_kingdoms_nb.csv" ]; then
    Rscript sign_otus_nyc.R -m nb -a FALSE -r FALSE
fi
# Zero inflated Poisson
if [ ! -f "../selected_variables_results/nyc_otus_list/nyc_otus_assembly_kingdoms_zip.csv" ]; then
    Rscript sign_otus_nyc.R -m zip -a FALSE -r FALSE
fi
# Zero inflated negative binomial
if [ ! -f "../selected_variables_results/nyc_otus_list/nyc_otus_assembly_kingdoms_zinb.csv" ]; then
    Rscript sign_otus_nyc.R -m zinb -a FALSE -r FALSE
fi
# With model selection
if [ ! -f "../selected_variables_results/nyc_otus_list/nyc_otus_assembly_kingdoms_best.csv" ]; then
    Rscript sign_otus_nyc.R -m best -a FALSE -r FALSE
fi
