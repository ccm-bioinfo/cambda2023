#!/usr/bin/env Rscript
library("optparse")

option_list = list(
    make_option(c("-I", "--input_dir"), type = "character", default = "../selected_variables_results/", 
                help = "input directory [default= %default]", metavar = "character"),
    make_option(c("-d", "--tax_data"), type = "character", default = "../selected_variables_results/otus_taxonomic/", 
                help = "directory where the taxonomic dictionaries are stored [default= %default]", metavar = "character"),
    make_option(c("-O", "--out_dir"), type = "character", default = "../selected_variables_results/relative_abundance_plots/", 
                help = "output directory [default= %default]", metavar = "character"),
    make_option(c("-r", "--reads"), type = "logical", default = TRUE,
                help = "reads (TRUE) or assembly (FALSE) [default= %default]", 
                metavar = "logical"),
    make_option(c("-k", "--kingdoms"), type = "logical", default = FALSE, 
                help = "kingdoms", metavar = "logical"),
    make_option(c("-R", "--reduced"), type = "logical", default = TRUE, 
                help = "reduced data", metavar = "logical"),
    make_option(c("-m", "--model"), type = "character", default = "nb",
                help = "model to adjust: Poisson (p), Negative Binomial (nb), Zero Inflated Poisson (zip) or Zero Inflated Negative Binomial (zinb) [default= %default]",
                metavar = "integer"),
    make_option(c("-l", "--level"), type = "character", default = "Order", 
                help = "hierarchical level for fill", metavar = "characer"),
    make_option(c("-u", "--usa"), type = "logical", default = TRUE, 
                help = "plots for USA", metavar = "logical")
); 

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

# 3 july 2023
# Imanol Nuñez
#-------------------------------------------------------------------------------
# Load libraries via pacman
pacman::p_load(ggplot2, ggthemes, phyloseq,                       # Plots
               dplyr, tibble, tidyr, purrr, broom, pscl)                 # Data frame manipulation 

#-------------------------------------------------------------------------------
# Create the plot 
prefix0 <- ifelse(opt$reads, "reads", "assembly")
prefix1 <- ifelse(opt$kingdoms, "kingdoms", "")
prefix2 <- opt$model
suffix0 <- ifelse(opt$reduced, "_reduced", "")
suffix1 <- ifelse(opt$usa, "_usa", "")

path_to_counts <- paste0(
    opt$input_dir, 
    ifelse(opt$reduced, "integrated_reduced_tables/", "integrated_tables/"), 
    prefix0, "_", prefix1, 
    "_", prefix2, "_integrated", suffix0, ".csv"
)
path_to_tax <- paste0(
    opt$input_dir, "otus_taxonomic/otus_", prefix0, "_", prefix1, "_", 
    prefix2, "_tax", suffix0, ".csv"
)
path_to_fig <- paste0(
    opt$out_dir, prefix0, "_", prefix1, "_", prefix2, "_relAbund", suffix0
    , suffix1, ".png"
)

counts <- read.csv(path_to_counts)
taxID <- read.csv(path_to_tax)

taxData <- taxID %>% 
    mutate(ID = paste0(OTU, "_", hlevel)) %>% 
    relocate("ID") %>% 
    select(-c("OTU", "locs", "hlevel", "sign_rank")) %>% 
    group_by(ID) %>% 
    distinct() %>% 
    column_to_rownames("ID")

sampleData <- data.frame(
        row.names = colnames(counts)[-1], 
        Sample_ID = colnames(counts)[-1]
    ) %>% 
    mutate(City = substr(Sample_ID, 24, 26),
           year = substr(Sample_ID, 21, 22), 
           City_year = paste0(City, "_", year))

if (opt$usa) {
    idx <- which(
        grepl("BAL", sampleData$City) | grepl("DEN", sampleData$City) | 
            grepl("MIN", sampleData$City) |grepl("NYC", sampleData$City) | 
            grepl("SAC", sampleData$City) | grepl("SAN", sampleData$City)
    )
} else {
    idx <- 1:nrow(sampleData)
}

sampleData <- sample_data(
    sampleData[idx, ]
)

phylo_sv <- phyloseq(
    counts[, c(1, idx + 1)] %>% column_to_rownames("ID") %>% 
        otu_table(taxa_are_rows = TRUE), 
    tax_table(as.matrix(taxData)),
    sampleData
)

phylo_sv_rel <- transform_sample_counts(phylo_sv, function(x) x / sum(x) )

rel_ab_sv <- plot_bar(phylo_sv_rel, fill = opt$level) +
    facet_grid(cols = vars(City_year), scales = "free") +
    theme_fivethirtyeight() +
    theme(axis.text.x = element_blank(),
          legend.position = "bottom",
          legend.margin = margin(),
          legend.text = element_text(size=rel(0.5))) +
    guides(fill = guide_legend(nrow = 5, byrow = TRUE))

ggsave(
    filename = path_to_fig,
    plot = rel_ab_sv,
    dpi = 180, width = 16, height = 9
)
