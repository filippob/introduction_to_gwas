#!/bin/bash

## prepare data for GWAS

plink=plink

## if imputed ped/map/Plink files have not been recoded to the 0/1/2 format (.raw)
## please uncomment the two lines of code below
#$plink --file ../3.imputation/rice_imputed --recode A --out rice_imputed
#$plink --dog --file ../3.imputation/dogs_imputed --recode A --out dogs_imputed

## stand-alone script
Rscript --vanilla gwas_rrblup.R genotype_file=../3.imputation/dogs_imputed.raw snp_map=../3.imputation/dogs_imputed.map phenotype_file=../data/dogs_phenotypes.txt trait=phenotype trait_label=cleft_lip
Rscript --vanilla gwas_rrblup.R genotype_file=../3.imputation/rice_imputed.raw snp_map=../3.imputation/rice_imputed.map phenotype_file=../data/rice_phenotypes.txt trait=PH trait_label=PH

echo "DONE!"
