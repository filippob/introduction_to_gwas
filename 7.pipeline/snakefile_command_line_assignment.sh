#!/bin/bash
## prepare the env

mkdir data 2>/dev/null
mkdir steps 2>/dev/null
cp -r ../software .
cp ../4.gwas/gwas_rrblup.R software

## dry run
#snakemake --dag -n -s Snakefile_GWAS.binary | dot -Tsvg > dag_dogs.svg
## full run
snakemake -s Snakefile_GWAS.parus
