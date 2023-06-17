library("phyloseq")
library("ggplot2")
library("RColorBrewer")
library("patchwork")
library("tidyr")
library("tidyverse")

setwd("~/CAMDA23/completos")


setwd("/home/shaday/GIT/ccm-bioinfomatica-lab/Hackaton_junio2023/Resistencia")

Camda=import_biom("data/assembly_365_2.biom")
Camda2=import_biom("data/read_365_2.biom")
# Cargar archivo .biom


raw_metagenomes <- import_biom("data/assembly_365_2.biom")
raw_metagenomes@tax_table@.Data <- substring(raw_metagenomes@tax_table@.Data, 4)
colnames(raw_metagenomes@tax_table@.Data)<- c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species")
View(raw_metagenomes@tax_table@.Data)


## Obtener metadatos

otu_t <- t(raw_metagenomes@otu_table@.Data)
names <- rownames(otu_t)
names <- as.data.frame(names)
ciudades <- separate(names, col=names, into=c("Camnda", "Meta", "Code", "City","Num"), sep="_")

code <- substr(ciudades$Code, start = 5, stop = 6)
code <- as.data.frame(code)
colnames(code) <- "Year"

ciudades <- cbind(names,ciudades, code)
colnames(ciudades)[1] <- "ID"

ciudades2 <- cbind(ciudades$ID, ciudades$City, ciudades$Year)
colnames(ciudades2) <- c("ID", "City", "Year")



ciudades2 <- as.data.frame(ciudades2)


cd <- ciudades2%>%
  count("City")

colnames(cd) <- c("City","Freq")


library(readr)
coord <- read_csv("metadata.csv")
View(coord)




cds <- coord %>% 
  filter(ID_city %in% unique(cd$City)) %>%
  mutate("Freq" = cd$Freq)

citys <- cds[rep(row.names(cds), cds$Freq), 1:4]




colnames(ciudades2)[2] <- "ID_city"

citys <- cbind(ciudades2$ID,citys, ciudades2$Year)


colnames(citys)[1] <- "ID"
colnames(citys)[6] <- "Year"


library(kgc)

coord2 <- data.frame(citys$ID, citys$ID_city,citys$City, citys$Year,
                     rndCoord.lat= RoundCoordinates(citys$Latitude),
                     rndCoord.lon= RoundCoordinates(citys$Longitude))

Climate <- data.frame(coord2, Climate= LookupCZ(coord2, res = "course")) 

colnames(Climate) <- c("ID", "ID_city", "City", "Year", "Latitude", "Longitude", "Climate")


otu <- cbind(Climate, otu_t)

colnames(otu)[1] <- "Sample"

write_csv(Climate, "metadata.csv", col_names = TRUE)


## Tablas de otus con metadatos

write_csv(otu, "otu.csv", col_names = TRUE)

relative_data <- transform_sample_counts(raw_metagenomes, function(x) x*100 / sum(x) )

relative_otu_t <- t(relative_data@otu_table@.Data)

relative_otu <- cbind(Climate, relative_otu_t)

colnames(relative_otu)[1] <- "Sample"

write_csv(relative_otu, "relative_otu.csv", col_names = TRUE)
