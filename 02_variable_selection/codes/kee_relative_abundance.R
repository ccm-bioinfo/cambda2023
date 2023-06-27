#!/usr/bin/env Rscript

# 27 june 2023
# Imanol Nuñez

#-------------------------------------------------------------------------------
# Load libraries via pacman
pacman::p_load(ggplot2, ggthemes, dplyr, tidyr)

# Load the genus data
genus_reads <- read.csv("../data/reads/reads_count__Genus.csv")
genus_assembly <- read.csv("../data/assembly/assembly_count__Genus.csv")

# Calculate relative abundances of kee from reads data
kee_reads <- genus_reads %>% 
    filter(
        X %in% c(550, 562, 570)
    ) %>% 
    pivot_longer(-X, names_to = "samples", values_to = "counts") %>% 
    pivot_wider(names_from = "X", values_from = "counts") %>% 
    rename(
        enterobacter = "550", escherichia = "562", klebsciella = "570"
    ) %>% 
    mutate(
        total = enterobacter + escherichia + klebsciella,
        enterobacter.rel = enterobacter / total,
        escherichia.rel = escherichia / total,
        klebsciella.rel = klebsciella / total
    ) %>% 
    select(-total) %>% 
    mutate(
        total = unlist(colSums(genus_reads[,-1])), 
        enterobacter.relTot = enterobacter / total,
        escherichia.relTot = escherichia / total,
        klebsciella.relTot = klebsciella / total,
    ) %>% 
    select(-total)

# Calculate relative abundances of kee from assembly data
kee_assembly <- genus_assembly %>% 
    filter(
        X %in% c(550, 562, 570)
    ) %>% 
    pivot_longer(-X, names_to = "samples", values_to = "counts") %>% 
    pivot_wider(names_from = "X", values_from = "counts") %>% 
    rename(
        enterobacter = "550", escherichia = "562", klebsciella = "570"
    ) %>% 
    mutate(
        total = enterobacter + escherichia + klebsciella,
        enterobacter.rel = enterobacter / total,
        escherichia.rel = escherichia / total,
        klebsciella.rel = klebsciella / total
    ) %>% 
    select(-total) %>% 
    mutate(
        total = unlist(colSums(genus_assembly[,-1])), 
        enterobacter.relTot = enterobacter / total,
        escherichia.relTot = escherichia / total,
        klebsciella.relTot = klebsciella / total,
    ) %>% 
    select(-total)

# Save the results
write.csv(
    kee_reads, 
    file = "../KEE/reads_kee.csv",
    row.names = FALSE
)
write.csv(
    kee_assembly, 
    file = "../KEE/assembly_kee.csv",
    row.names = FALSE
)
