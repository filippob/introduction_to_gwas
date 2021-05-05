*Functional Analysis*

This tutorial explains how to extract the genes from statistcally associated SNPs from the GWAS, and infer their functionality.

First we need to download the background genes from our specie of study. These are the known genes that are carried by the specie. In our case, we are going to use the dog data. so we download the genes from the Canis familiaris specie.

Download bkg genes:  [https://www.ensembl.org/info/data/ftp/index.html] 


Results overview in FUMA
https://fuma.ctglab.nl/snp2gene
Input file: GWASresults.txt
Variant Effect Prediction in Ensembl
https://www.ensembl.org/Multi/Tools/VEP
Input file (significant SNPs): Map.selected.rs
Output file (Functional Info): Select ‘Gene’ column
Enrichment analysis
https://fuma.ctglab.nl/gene2func
Input files: GENES from significant SNPs (’Gene’ column from VEP) Background genes from the specie (Canis_familiaris.bkg_genes)
