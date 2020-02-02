#!/bin/bash
## prepare the env

mkdir data 2>/dev/null
mkdir steps 2>/dev/null
cp -r ../software .
cp ../4.gwas/gwas.R software
#cp ../1.preparatory_steps/get_data_parus.sh software
#cp ../1.preparatory_steps/prepare_data.R software
cp -r ../data/{dogs,rice}.{ped,map} data
cp -r ../data/{dogs,rice}_phenotypes.txt data

## dry run
#snakemake --dag -s Snakefile_GWAS_continuous | dot -Tsvg > graph.svg
snakemake -s Snakefile_GWAS_continuous
