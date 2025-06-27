#!/bin/bash
## prepare the env

mkdir -p data 2>/dev/null
mkdir -p steps 2>/dev/null

cp -r ../software .
cp ../4.gwas/gwas_* software ## which script do we want to use for GWAS?
cp ../1.preparatory_steps/prep_rice_data_pipeline.R software
cp ../cross_reference/rice_group.reference software
cp ../3.imputation/knni_tidymodels.R software

## make DAG
snakemake --dag -s Snakefile_GWAS.continuous_knni | dot -Tsvg > dag_knni.svg
## full run
snakemake -s Snakefile_GWAS.continuous_knni --cores 4
