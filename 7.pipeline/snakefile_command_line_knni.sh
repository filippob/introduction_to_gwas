#!/bin/bash
## prepare the env

mkdir data 2>/dev/null
mkdir steps 2>/dev/null
cp -r ../software .
cp ../4.gwas/gwas_* software ## which script do we want to use for GWAS?
cp ../1.preparatory_steps/prep_rice_data.R software
cp ../cross_reference/rice_group.reference software
cp ../3.imputation/knni_tidymodels.R software

## dry run
snakemake --dag -n -s Snakefile_GWAS.continuous_knni | dot -Tsvg > dag_knni.svg
## full run
snakemake -s Snakefile_GWAS.continuous_knni
