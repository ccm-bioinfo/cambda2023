# Variable selection
Our goal is to select OTUs considering the possible zero inflated data and evaluate if this modeling impacts in the forensic challenge of city prediction.

First we are subsetting the complete OTU table into the following tables:

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

All of the previous tables are constructed using [reads](./data/reads) and [assembbly](./data/reads) data. 

## 2023 06 03  
We agglomerated two OTU tables: reads-OTU table and one for assemblies into several tables by taxonomic agglomeration.  
We model the distribution of zero's in the all kingdoms-phylum table.  
We run machine learning models (Victor's code) in the original reads-OTU table. 

To select the variables, we consider the classical models for count data:

- Poisson regression
- Negative binomial regression

Furthermore, to account for a possible excess of zeros we consider the corresponding zero inflated models. 
Given one of the four possible models, for every OTU and each pair of cities we fit the model and check the p-value corresponding to the effect produced by a city. 
To select the differentiating OTUs we compute p-values and for every pair of cities we select a fixed number of OTUs with the best (lowest) p-values. 
This selection is mostly automatized in the script [variable_selection.R](./codes/variable_selection.R). 
The method works at both assembly and reads levels, for every subset of kindoms obtained previously.

We also propose a method to select the variable but considering the model that fits best the count data, for each OTU, among the Poisson (P), Negative Binomial (NB), Zero Inflated (ZI) Poisson and (ZINB). 
This method is found in the script [variable_selection_with_model_selection.R](./codes/variable_selection_with_model_selection.R).
