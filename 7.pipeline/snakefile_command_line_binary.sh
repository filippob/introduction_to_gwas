#!/bin/bash
## prepare the env

mkdir data
mkdir steps
cp -r ../introduction_to_gwas/software .
cp ../introduction_to_gwas/4.gwas/gwas_rrblup.R software
cp ../introduction_to_gwas/4.gwas/gwas_sommer.R software
cp ../introduction_to_gwas/1.preparatory_steps/prep_dogpheno.R software

## dry run
snakemake --dag -n -s Snakefile_GWAS.binary | dot -Tsvg > dag_dogs.svg

## full run
#snakemake -s Snakefile_GWAS.binary


