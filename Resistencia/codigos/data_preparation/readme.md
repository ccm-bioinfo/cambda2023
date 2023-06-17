
- join_card_data.py

Uses the information from the card database (found in aro.obo and aro_index.tsv) and appends to the count table (amr-counts_20230604.tsv) all the metadata in card for each AMR marker to be used later in assigning a class to each marker. Note all the markers are stripped from any non alphanumeric symbol to reduce missnomers, but some still needed to be fixed by hand (lines 129 - 134). Output amr-counts_card_info.tsv

- collapse_amr_counts.py

Aggregates all the rows belonging to the same class (found in column 7). This class was decided in a manual curation using the information provided by card (amr_counts_class.tsv). Output amr_counts_collapsed_count_variants.tsv


- Preprocessing of amr data:

- - parse_mistery_samples.py

Parses the mystery sample (amr_patterns.tsv) into a count table. Additionally it can convert the gene names to ARO ids from card if they are found in the database. Output amr_mistery_table.tsv

- - parse_missing_amr_to_fasta.py
Parses the table from https://docs.google.com/spreadsheets/d/1ThsVn6QuIEPvFqe_SwG1PawEghqHgQdvNgGiZd40jXY/edit#gid=72799943 exported as tsv into a fasta file. Output missingAmr.fasta

- - parse_missing_amr.py
Takes a list of missing amr markers and add from the mystery sample (amr_patterns.tsv) the species it appeared in. Output missingAmr_species.tsv

- - blastScript.sh
Blasts the query sequence to all the fasta files in the data folder.

- - parse_blast.py
Parses the results from blastScript.sh (blastAll.txt) to generate the count table, requires the list of gene markers (amrMysteryList.txt) to assign the columns

## References  
[ ][CARD database](https://card.mcmaster.ca/download)  
