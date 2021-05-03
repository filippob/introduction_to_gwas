#!/bin/bash
## prepare the env

mkdir data 2>/dev/null
mkdir steps 2>/dev/null
cp -r ../software .
cp ../4.gwas/gwas_* software ## which script do we want to use for GWAS?

## dry run
snakemake --dag -n -s Snakefile_GWAS.parus | dot -Tsvg > dag_parus.svg
## full run
snakemake -s Snakefile_GWAS.parus
