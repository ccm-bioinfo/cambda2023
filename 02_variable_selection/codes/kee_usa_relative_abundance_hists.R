#!/usr/bin/env Rscript

# 27 june 2023
# Imanol Nuñez

#-------------------------------------------------------------------------------
# Load libraries via pacman
pacman::p_load(ggplot2, ggthemes, dplyr)

# Read the data where the relative abundances of KEE are already computed
kee_data <- read.csv("../KEE/reads_kee.csv")

# Filter only the samples that correspond to USA cities
kee_data <- kee_data %>% 
    mutate(
        samples = paste0(substr(samples, 24, 26), "_", substr(samples, 21, 22))
    ) %>% 
    filter(
        grepl("BAL", samples) | grepl("DEN", samples) | grepl("MIN", samples) |
            grepl("NYC", samples) | grepl("SAC", samples) | grepl("SAN", samples)
    )

# Plot histograms of the percentages 
EnteroPlot <- kee_data %>% 
    ggplot(aes(x = enterobacter.relTot)) +
    geom_histogram() +
    facet_wrap(~samples, scales = "free") + 
    theme_fivethirtyeight() + 
    ggtitle("Histograms of relative abundance of Enterobacter in USA cities samples") +
    scale_x_continuous(breaks = breaks_extended(), labels = scales::scientific)

EscheriPlot <- kee_data %>% 
    ggplot(aes(x = escherichia.relTot)) +
    geom_histogram() +
    facet_wrap(~samples, scales = "free") + 
    theme_fivethirtyeight() + 
    ggtitle("Histograms of relative abundance of Escherichia in USA cities samples") +
    scale_x_continuous(breaks = breaks_extended(), labels = scales::scientific)

KlebscPlot <- kee_data %>% 
    ggplot(aes(x = klebsciella.relTot)) +
    geom_histogram() +
    facet_wrap(~samples, scales = "free") + 
    theme_fivethirtyeight() + 
    ggtitle("Histograms of relative abundance of Escherichia in USA cities samples") +
    scale_x_continuous(breaks = breaks_extended(), labels = scales::scientific)

# Save the plots
ggsave(
    plot = EnteroPlot, 
    filename = "../../06_amr_resistance/fig/relative_abundance_enterobacter_usa.png",
    dpi = 180, width = 12, height = 6.75
)

ggsave(
    plot = EscheriPlot, 
    filename = "../../06_amr_resistance/fig/relative_abundance_escherichia_usa.png",
    dpi = 180, width = 12, height = 6.75
)

ggsave(
    plot = KlebscPlot, 
    filename = "../../06_amr_resistance/fig/relative_abundance_klebsciella_usa.png",
    dpi = 180, width = 12, height = 6.75
)
