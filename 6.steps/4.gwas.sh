#!/bin/bash

## prepare data for GWAS

plink=plink

$plink --file rice_imputed --recode A --out rice_imputed
$plink --dog --file dogs_imputed --recode A --out dogs_imputed

## stand-alone script
Rscript --vanilla gwas_rrblup.R genotype_file=dogs_imputed.raw snp_map=dogs_imputed.map phenotype_file=data/dogs_phenotypes.txt trait=phenotype trait_label=cleft_lip
Rscript --vanilla gwas_sommer.R genotype_file=rice_imputed.raw snp_map=rice_imputed.map phenotype_file=data/rice_phenotypes.txt trait=PH trait_label=plant_height covariates=population
Rscript --vanilla gwas_statgengwas.R genotype_file=rice_imputed.raw snp_map=rice_imputed.map phenotype_file=data/rice_phenotypes.txt trait=PH trait_label=plant_height systematic_effects=population
Rscript --vanilla gwas_rrblup.R genotype_file=rice_imputed.raw snp_map=rice_imputed.map phenotype_file=data/rice_phenotypes.txt trait=PH trait_label=plant_height
