#!/bin/bash
## prepare the env

mkdir -p data
mkdir -p steps
cp -r ../software .
cp ../4.gwas/gwas_rrblup.R software
cp ../4.gwas/gwas_sommer.R software
cp ../1.preparatory_steps/prep_dogpheno.R software

## make DAG
snakemake --dag -s Snakefile_GWAS.binary | dot -Tsvg > dag_dogs_sommer.svg

## full run
#snakemake -s Snakefile_GWAS.binary --cores 1


