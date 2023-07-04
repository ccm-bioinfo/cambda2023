#!/bin/bash

Rscript relative_abundance_with_selected_variables.R -l Phylum -m p
Rscript relative_abundance_with_selected_variables.R -l Order -m nb
Rscript relative_abundance_with_selected_variables.R -l Order -m zip
Rscript relative_abundance_with_selected_variables.R -l Order -m zinb
Rscript relative_abundance_with_selected_variables.R -l Order -m best

Rscript relative_abundance_with_selected_variables.R -R FALSE -l Phylum -m p
Rscript relative_abundance_with_selected_variables.R -R FALSE -l Order -m nb
Rscript relative_abundance_with_selected_variables.R -R FALSE -l Order -m zip
Rscript relative_abundance_with_selected_variables.R -R FALSE -l Order -m zinb
Rscript relative_abundance_with_selected_variables.R -R FALSE -l Order -m best

Rscript relative_abundance_with_selected_variables.R -k TRUE -l Phylum -m p
Rscript relative_abundance_with_selected_variables.R -k TRUE -l Order -m nb
Rscript relative_abundance_with_selected_variables.R -k TRUE -l Order -m zip
Rscript relative_abundance_with_selected_variables.R -k TRUE -l Order -m zinb
Rscript relative_abundance_with_selected_variables.R -k TRUE -l Order -m best

Rscript relative_abundance_with_selected_variables.R -k TRUE -R FALSE -l Phylum -m p
Rscript relative_abundance_with_selected_variables.R -k TRUE -R FALSE -l Order -m nb
Rscript relative_abundance_with_selected_variables.R -k TRUE -R FALSE -l Order -m zip
Rscript relative_abundance_with_selected_variables.R -k TRUE -R FALSE -l Order -m zinb
Rscript relative_abundance_with_selected_variables.R -k TRUE -R FALSE -l Order -m best
