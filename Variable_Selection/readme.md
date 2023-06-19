# Variance reduction
Our goal is to reduce zeros in Zero inflated data and evaluate if this modeling impacts in the forensic challenge of city prediction. 
First we are subseting the total OTU table into the following tables.

- Archaea and Bacteria Phylum    
- Archaea and Bacteria Class    
- Archaea and Bacteria Order   
- Archaea and Bacteria Family   
- Archaea and Bacteria Genus  

- Eukarya Phylum  
- Eukarya Class   
- Eukarya Order  
- Eukarya Family   
- Eukarya Genus  

- Virus Phylum   
- Virus Class   
- Virus Order   
- Virus Family   
- Virus Genus  

- All Kingdoms Phylum   
- All Kingdoms Class   
- All Kingdoms Order   
- All Kingdoms Family   
- All Kingdoms Genus  

## 2023 06 03  
We glomed two OTU tables:reads-OTU table and one for assemblies into several tables by taxonomic agglomeration.  
We model the distribution of zero's in the all kingdoms-phylum table.  
We run machine learning models (Victor's code) in the original reads-OTU table. 

## Variable selection
We propose a method to select OTUs that help us differentiate at least two of the cities. 
The proposed selection uses negative binomial regression to account for overdispersion of absolute abundance, caused both by zeros and high level counts. 
To select the differentiating OTUs we compute p-values and for every pair of cities we select a fixed number of OTUs with the best (lowest) p-values. 
This selection is mostly automatized in the script [variable_selection.R](./codes/variable_selection.R). 
The method works at both assembly and reads levels, for every subset of kindoms obtained previously.

We also propose a method to select the variable but considering the model that fits best the count data, for each OTU, among the Poisson (P), Negative Binomial (NB), Zero Inflated (ZI) Poisson and (ZINB). 
This method is found in the script [variable_selection_with_model_selection.R](./codes/variable_selection_with_model_selection.R).
