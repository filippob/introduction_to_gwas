#!/bin/bash

## prepare data for GWAS (Arthur Korte)

plink=/home/filippo/Downloads/plink

$plink --file ../3.imputation/rice_imputed --recode A --out rice_imputed
$plink --dog --file ../3.imputation/dogs_imputed --recode A --out dogs_imputed

cp ../3.imputation/*_imputed.map .

## stand-alone script
Rscript --vanilla gwas.R genotype_file=dogs_imputed.raw snp_map=../3.imputation/dogs_imputed.map phenotype_file=../data/dogs_phenotypes.txt trait=phenotype trait_label=cleft_lip

Rscript --vanilla gwas.R genotype_file=rice_imputed.raw snp_map=../3.imputation/rice_imputed.map phenotype_file=../data/rice_phenotypes.txt trait=PH trait_label=PH

## pipeline
