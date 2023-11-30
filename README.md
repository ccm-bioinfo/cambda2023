# Camda 2023 Mexican Team
- [Presentation Talk](https://docs.google.com/presentation/d/1AM7f3khAGLN8pXDnDs9BOYrUh56jCmPwoc2MRLTkfgg/edit#slide=id.g24bcac0919d_0_1109)  
- [Poster Presentation](https://docs.google.com/presentation/d/1y93GOJ49hvfOcMjYxObsL0WITbK4ZtDRAqbZ6paRE9c/edit#slide=id.g22edbecd1bc_12_40)
- [Poster File](https://docs.google.com/presentation/d/17jPeWFA5W74l-NPQVnPGYkuCVM2H4maemu8yY9zGknM/edit#slide=id.p)
- [Plan google sheet](https://docs.google.com/spreadsheets/d/1GRxtgu_4-9FCARIu2ke_AxGVEQxKd_TSnKtql4LroiU/edit#gid=622084973)

## Anti-Microbial Resistance Prediction and Forensics Challenge
The goal will be to explore metagenomic surveillance data from a selection of about 400 samples provided by MetaSUB International Consortium collected during global City Sampling Day 2016 and 2017 in several cities in US (Baltimore, Denver, Mineapollis, New York, Sacramento, San Antonio) and worldwide (Berlin, Bogota, Doha, Ilorin, Lisbon, Sao Paulo, Tokyo, Vienna, Zurich) to trace the AMR patterns.

A focus should be placed especially on AMR markers and resistance groups identified in about 150 isolates from hospital in one of abovementioned US cities collected in similar time. Can you tell which one? As it was shown in the past CAMDA challenges an antibiotic resistance as functional biomarkers can accurately predict the origin of urban metagenomics samples.

You are welcome to use your imagination to carry out any side analysis that you would like, using the provided datasets. That is why we do provide, in addition as a non-urban context, a selection of soil microbiome samples from EMP500 project can be used.
## Data 
Here we need to fix the links! 
Reads after trimming are stored by duplicate in Chihuil /botete/mvazquez/camda2023/trimmed/*.fastq.gz and Alnitak /data/camda2023/trimmed/*.fastq.gz  
Taxonomical data tables  
- [OTU table from reads](https://github.com/ccm-bioinfo/cambda2023/blob/main/01_preprocessing/taxonomy/read-biom.tsv.gz)
  
|   |Bacteria-Archaea | Virus   | Eukarya  | All   |  
|---|---|---|---|---|  
|Phylum   | [Bacteria-Phylum](./02_variable_selection/data/reads/readsAB_count__Phylum.csv)  | [Virus-Phylum](./02_variable_selection/data/reads/readsViruses_count__Phylum.csv)   | [Eukarya-Phylum](./02_variable_selection/data/reads/readsEukarya_count__Phylum.csv)  | [All-Phylum](./02_variable_selection/data/reads/reads_count__Phylum.csv)   |   
|Family   | [Bacteria-Family](./02_variable_selection/data/reads/readsAB_count__Family.csv)  | [Virus-Family](./02_variable_selection/data/reads/readsViruses_count__Family.csv)   | [Eukarya-Family](./02_variable_selection/data/reads/readsEukarya_count__Family.csv)  | [All-Family](./02_variable_selection/data/reads/reads_count__Family.csv)   |   
|Class   | [Bacteria-Class](./02_variable_selection/data/reads/readsAB_count__Class.csv)  | [Virus-Class](./02_variable_selection/data/reads/readsViruses_count__Class.csv)   | [Eukarya-Class](./02_variable_selection/data/reads/readsEukarya_count__Class.csv)  | [All-Class](./02_variable_selection/data/reads/reads_count__Class.csv)   |   
|Order   | [Bacteria-Order](./02_variable_selection/data/reads/readsAB_count__Order.csv)  | [Virus-Order](./02_variable_selection/data/reads/readsViruses_count__Order.csv)   | [Eukarya-Order](./02_variable_selection/data/reads/readsEukarya_count__Order.csv)  | [All-Order](./02_variable_selection/data/reads/reads_count__Order.csv)   |   
|Genera   | [Bacteria-Genus](./02_variable_selection/data/reads/readsAB_count__Genus.csv)  | [Virus-Genus](./02_variable_selection/data/reads/readsViruses_count__Genus.csv)   | [Eukarya-Genus](./02_variable_selection/data/reads/readsEukarya_count__Genus.csv)  | [All-Genus](./02_variable_selection/data/reads/reads_count__Genus.csv)   |   

- [OTU table with assemblies](https://github.com/ccm-bioinfo/cambda2023/blob/main/01_preprocessing/taxonomy/assembly-biom.tsv.gz)  
  
|   |Bacteria-Archaea | Virus   | Eukarya  | All   |  
|---|---|---|---|---|  
|Phylum   | [Bacteria-As-Phylum](./02_variable_selection/data/assembly/assemblyAB_count__Phylum.csv)  | [Virus-As-Phylum](./02_variable_selection/data/assembly/assemblyViruses_count__Phylum.csv)   | [Eukarya-As-Phylum](./02_variable_selection/data/assembly/assemblyEukarya_count__Phylum.csv)  | [All-As-Phylum](./02_variable_selection/data/assembly/assembly_count__Phylum.csv)   |   
|Family   | [Bacteria-As-Family](./02_variable_selection/data/assembly/assemblyAB_count__Family.csv)  | [Virus-As-Family](./02_variable_selection/data/assembly/assemblyViruses_count__Family.csv)   | [Eukarya-As-Family](./02_variable_selection/data/assembly/assemblyEukarya_count__Family.csv)  | [All-As-Family](./02_variable_selection/data/assembly/assembly_count__Family.csv)   |   
|Class   | [Bacteria-As-Class](./02_variable_selection/data/assembly/assemblyAB_count__Class.csv)  | [Virus-As-Class](./02_variable_selection/data/assembly/assemblyViruses_count__Class.csv)   | [Eukarya-As-Class](./02_variable_selection/data/assembly/assemblyEukarya_count__Class.csv)  | [All-As-Class](./02_variable_selection/data/assembly/assembly_count__Class.csv)   |   
|Order   | [Bacteria-As-Order](./02_variable_selection/data/assembly/assemblyAB_count__Order.csv)  | [Virus-As-Order](./02_variable_selection/data/assembly/assemblyViruses_count__Order.csv)   | [Eukarya-As-Order](./02_variable_selection/data/assembly/assemblyEukarya_count__Order.csv)  | [All-As-Order](./02_variable_selection/data/assembly/assembly_count__Order.csv)   |   
|Genera   | [Bacteria-As-Genus](./02_variable_selection/data/assembly/assemblyAB_count__Genus.csv)  | [Virus-As-Genus](./02_variable_selection/data/assembly/assemblyViruses_count__Genus.csv)   | [Eukarya-As-Genus](./02_variable_selection/data/assembly/assemblyEukarya_count__Genus.csv)  | [All-As-Genus](./02_variable_selection/data/assembly/assembly_count__Genus.csv)   |   

### Functional Analysis

- MetaCyc:
  - [Noncummulative unscaled tables](https://github.com/ccm-bioinfo/cambda2023/tree/main/funcional/data/metagenomic/tables/metacyc/noncummulative/unscaled)
  - [Noncummulative scaled tables](https://github.com/ccm-bioinfo/cambda2023/tree/main/funcional/data/metagenomic/tables/metacyc/noncummulative/scaled)
  - [Cummulative unscaled tables](https://github.com/ccm-bioinfo/cambda2023/tree/main/funcional/data/metagenomic/tables/metacyc/cummulative/unscaled)
  - [Cummulative scaled tables](https://github.com/ccm-bioinfo/cambda2023/tree/main/funcional/data/metagenomic/tables/metacyc/cummulative/scaled)
- [Mi-Faser tables](https://github.com/ccm-bioinfo/cambda2023/tree/main/funcional/data/metagenomic/tables/mifaser)
- [KEGG table](https://github.com/ccm-bioinfo/cambda2023/blob/main/funcional/data/metagenomic/tables/kegg.tsv)
- [UniProt table (compressed)](https://github.com/ccm-bioinfo/cambda2023/blob/main/funcional/data/metagenomic/tables/uniprot.tsv.gz)
- [VFDB table (compressed)](https://github.com/ccm-bioinfo/cambda2023/blob/main/funcional/data/metagenomic/tables/vfdb.tsv.gz)

### Resistance Table   
[Original table from mysterious sample](01_preprocessing/amr_patterns.tsv)  
[AMR Table](06_amr_resistance/data/230701_AMR_mysterious_NCBI_all_nelly.csv) 
Server Alnitak: /data/camda2023/genomes/assemblies/*.gbff

### Reduced variables table 
These tables are the result of the reduced variable team.  
Imanol 👀[Fix me]

For models fitted with all kingdoms:

|    | Poisson | Negative Binomial | Zero Inflated Poisson | Zero Inflated Negative Binomial |
|---|---|---|---|---|
|Reads | [Reads-P](./02_variable_selection/selected_variables_results/integrated_tables/reads__p_integrated.csv) | [Reads-NB](./02_variable_selection/selected_variables_results/integrated_tables/reads__nb_integrated.csv) | [Reads-ZIP](./02_variable_selection/selected_variables_results/integrated_tables/reads__zip_integrated.csv) | [Reads-ZINB](./02_variable_selection/selected_variables_results/integrated_tables/reads__zinb_integrated.csv) |
|Assembly | [Assembly-P](./02_variable_selection/selected_variables_results/integrated_tables/assembly__p_integrated.csv) | [Assembly-NB](./02_variable_selection/selected_variables_results/integrated_tables/assembly__nb_integrated.csv) | [Assembly-ZIP](./02_variable_selection/selected_variables_results/integrated_tables/assembly__zip_integrated.csv) | [Assembly-ZINB](./02_variable_selection/selected_variables_results/integrated_tables/assembly__zinb_integrated.csv) |

For models fitted considering each kingdom separately:

|    | Poisson | Negative Binomial | Zero Inflated Poisson | Zero Inflated Negative Binomial |
|---|---|---|---|---|
|Reads | [Reads-Sep-P](./02_variable_selection/selected_variables_results/integrated_tables/reads_kingdoms_p_integrated.csv) | [Reads-Sep-NB](./02_variable_selection/selected_variables_results/integrated_tables/reads_kingdoms_nb_integrated.csv) | [Reads-Sep-ZIP](./02_variable_selection/selected_variables_results/integrated_tables/reads_kingdoms_zip_integrated.csv) | [Reads-Sep-ZINB](./02_variable_selection/selected_variables_results/integrated_tables/reads_kingdoms_zinb_integrated.csv) |
|Assembly | [Assembly-Sep-P](./02_variable_selection/selected_variables_results/integrated_tables/assembly_kingdoms_p_integrated.csv) | [Assembly-Sep-NB](./02_variable_selection/selected_variables_results/integrated_tables/assembly_kingdoms_nb_integrated.csv) | [Assembly-Sep-ZIP](./02_variable_selection/selected_variables_results/integrated_tables/assembly_kingdoms_zip_integrated.csv) | [Assembly-Sep-ZINB](./02_variable_selection/selected_variables_results/integrated_tables/assembly_kingdoms_zinb_integrated.csv) |

Additionally, we compared the fitted models for each OTU and pair of cities, choosing the one with the lowest AIC. The tables with the selected variables using this model selection are listed next:

|   | Reads | Assembly |
|---|---|---|
|All kingdoms | [Reads-Best](./02_variable_selection/selected_variables_results/integrated_tables/reads__best_integrated.csv) | [Assembly-Best](./02_variable_selection/selected_variables_results/integrated_tables/assembly__best_integrated.csv) |
|Separated | [Reads-Sep-Best](./02_variable_selection/selected_variables_results/integrated_tables/reads_kingdoms_best_integrated.csv) | [Assembly-Sep-Best](./02_variable_selection/selected_variables_results/integrated_tables/assembly_kingdoms_best_integrated.csv) |

Welcome to Cambda 2023! 
### Relevant links
[Link a la presentación](https://docs.google.com/presentation/d/1AM7f3khAGLN8pXDnDs9BOYrUh56jCmPwoc2MRLTkfgg/edit#slide=id.g24bcac0919d_0_1109) 
[Hypothesis testing presentation](https://docs.google.com/presentation/d/1-qJd4-2TZXH2kP6S08iNl8AY2kt0TlMMJKaS4yzM0XM/edit#slide=id.g226f7d9b690_1_1)
[Classification presentation](https://docs.google.com/presentation/d/1N3uOvBw1reHhLpv-PvflEhafwmfr2xbPE5hmKjvH2YY/edit)
[Variable Reduction]()
[Link Data Zenodo](https://zenodo.org/record/8003231)    
[Carpeta de Trabajo Drive](https://drive.google.com/drive/folders/1vGOGMFTnl7k6A9n99KvYtZNmdANQCGOG?usp=drive_link)  
[Documento Resultados](https://docs.google.com/document/d/15g4cXKPa0Vthr3SUdVO-0EDLhMhDyhp3ZDhNoX7_8I8/edit)  
[Link scripts Haydee ](https://github.com/HaydeePeruyero/CAMDA2023/blob/main/script.R)   
[Link data curation Anton](https://github.com/aapashkov/camda2023)    
[Link Working plan and directory ](https://docs.google.com/document/d/1EU4fH89YuOGa69FY7ZQnr-qhI2kPKHqEZBd-WUE5mvg/edit#)  
[Aulas virtuales UNAM para entrar al material de curso ](https://aulas-virtuales.cuaieed.unam.mx/)   
[Link Victor Code]()   




## Submission Requirements


- All research submitted to CAMDA must be previously unpublished original work intended for publication, including procedures and results.
- Challenge data set embargo: Any challenge data that is not already in the public domain remains exclusive for participants in the contest until the conference presentation. This means that no publication of your results is allowed prior to the CAMDA conference. Once research has been accepted for publication at CAMDA, however, dissemination by pre-print servers is fine and encouraged.
- Research introducing data sets outside the set CAMDA challenges need to put these data in the context of the challenges and make both raw and derived data publicly available if the submitted work is accepted.
- Methods research needs to include at least two independent types of validation, such as a benchmark on simulated data with known truth, a benchmark on real-world data with built-in truths, or an application to real-world data with critical biological / medical interpretation.
- Researchers introducing novel computational approaches must make their procedure available to others (e.g., source code or commercial demo), and a publication of source code is strongly encouraged.



## References  
[ ][Antibiotic resistance and metabolic profiles as functional biomarkers that accurately predict the geographic origin of city metagenomics samples
](https://biologydirect.biomedcentral.com/articles/10.1186/s13062-019-0246-9)  
[ ][Forensic Applications of Microbiomics: A Review](https://www.frontiersin.org/articles/10.3389/fmicb.2020.608101/full)  
[ ][Identification of city specific important bacterial signature for the MetaSUB CAMDA challenge microbiome data](https://link.springer.com/article/10.1186/s13062-019-0243-z)    
[ ][Editorial: Critical assessment of massive data analysis (CAMDA) annual conference 2021](https://www.frontiersin.org/articles/10.3389/fgene.2023.1154398/full)     
[ ][Unraveling city-specific signature and identifying sample origin locations for the data from CAMDA MetaSUB challenge](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7780616/)      
[ ][Unraveling City-Specific Microbial Signatures and Identifying Sample Origins for the Data From CAMDA 2020 Metagenomic Geolocation Challenge](https://pubmed.ncbi.nlm.nih.gov/34421984/)   
[ ][Metagenomic Geolocation Using Read Signatures](https://pubmed.ncbi.nlm.nih.gov/35295949/)    
[ ][Identification of city specific important bacterial signature for the MetaSUB CAMDA challenge microbiome data](https://pubmed.ncbi.nlm.nih.gov/31340852/)  
[ ][Unraveling bacterial fingerprints of city subways from microbiome 16S gene profiles](https://pubmed.ncbi.nlm.nih.gov/29789016/)  
[ ][Fingerprinting cities: differentiating subway microbiome functionality](https://pubmed.ncbi.nlm.nih.gov/31666099/)  
[ ][Origin Sample Prediction and Spatial Modeling of Antimicrobial Resistance in Metagenomic Sequencing Data](https://pubmed.ncbi.nlm.nih.gov/33763122/)
[ ][Application of machine learning techniques for creating urban microbial fingerprints](https://pubmed.ncbi.nlm.nih.gov/31420049/)   
[ ][Metagenomic Geolocation Prediction Using an Adaptive Ensemble Classifier](https://pubmed.ncbi.nlm.nih.gov/33959149/)    
[ ][Massive metagenomic data analysis using abundance-based machine learning](https://pubmed.ncbi.nlm.nih.gov/31370905/)  
[ ][Environmental metagenome classification for constructing a microbiome fingerprint](https://pubmed.ncbi.nlm.nih.gov/31722729/)   
[ ][A machine learning framework to determine geolocations from metagenomic profiling](https://pubmed.ncbi.nlm.nih.gov/33225966/)  
[ ][Profiling microbial strains in urban environments using metagenomic sequencing data](https://pubmed.ncbi.nlm.nih.gov/29743119/)   
[ ][Systematic evaluation of supervised machine learning for sample origin prediction using metagenomic sequencing data](https://pubmed.ncbi.nlm.nih.gov/33302990/)  
[ ][MetaBinG2: a fast and accurate metagenomic sequence classification system for samples with many unknown organisms](https://pubmed.ncbi.nlm.nih.gov/30134953/)  
[ ][Assessment of urban microbiome assemblies with the help of targeted in silico gold standards](https://pubmed.ncbi.nlm.nih.gov/30621760/)  
[ ][Metagenomics Analyses: A Qualitative Assessment Tool for Applications in Forensic Sciences](https://link.springer.com/chapter/10.1007/978-981-15-6529-8_5)  
[ ][Forensic Applications of Microbiomics: A Review](https://www.frontiersin.org/articles/10.3389/fmicb.2020.608101/full)  
[ ][Application of Microbiome in Forensics](https://www.sciencedirect.com/science/article/pii/S1672022922000961)  
[ ][Environmental metagenomics in urban environments and development of forensic inference](https://www.kcl.ac.uk/research/environmental-metagenomics-in-urban-environments-and-development-of-forensic-inference)  
[ ][Origin Sample Prediction and Spatial Modeling of Antimicrobial Resistance in Metagenomic Sequencing Data](https://pubmed.ncbi.nlm.nih.gov/33763122/)  
