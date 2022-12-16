# Functional Analysis in FUMA

**This tutorial explains how to extract the genes from statistically associated SNPs from the GWAS, and infer their functionality.**

First, we need to download the background genes from our specie of study. These are the known genes that are carried by the specie. In our case, we are going to use the dog data. so we download the genes from the Canis familiaris specie.

Download [bkg genes](https://www.ensembl.org/info/data/ftp/index.html)

We run the R code *[getGenesFromSNP](getGenesFromSNP.R)* to obtain the candidate genes that host the SNPs resulted significant in the GWAS. The output is saved in the file *gwas_genesCfamiliaris.csv*.

Then, we log in [FUMA](https://fuma.ctglab.nl/gene2func).



<p align="center">
  <img width="800" height="200" src="menu.PNG">
</p>

The results from the R program is the input file *gwas_genesCfamiliaris.txt*, that contains GENES from significant SNPs (’Gene’ column) in the *Genes of interest* option, whereas the background genes must be used as input in the corresponding option.
Then, click submit.

# Functional Analysis in DAVID

Follow the steps provided in the [presentation](../slides/Functional_Analysis.pdf)
