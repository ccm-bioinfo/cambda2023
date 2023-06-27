#!/bin/bash

# Compute the relative abundances of KEE in all samples
Rscript kee_relative_abundance.R
# Plot the histogram of relative abundances in USA cities
Rscript kee_usa_relative_abundance_hists.R
