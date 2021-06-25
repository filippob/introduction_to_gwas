#!/bin/bash
## prepare the env

mkdir data
mkdir steps
cp -r ../software .
cp ../4.gwas/gwas_rrblup.R software
cp ../4.gwas/gwas_sommer.R software
cp ../1.preparatory_steps/prep_dogpheno.R software

## dry run
snakemake --dag -n -s Snakefile_GWAS.binary | dot -Tsvg > dag_dogs_sommer.svg

## full run
#snakemake -s Snakefile_GWAS.binary


