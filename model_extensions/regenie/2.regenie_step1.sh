#!/bin/bash
#########################
## REGENIE - step 1
#########################

## command lines (and instruction) to run regenie step 1
plink=$HOME/software/plink/plink
regenie=$HOME/Documents/software/regenie_v3.2.2.gz_x86_64_Linux
#regenie=regenie
thinning=0.01
genotypef=rice/rice_regenie
covf=rice/covariates.tsv
phenof=rice/phenotypes.tsv
fname="$(basename -- $genotypef)_res"
outdir=rice


$regenie \
  --step 1 \
  --bed ${genotypef} \
  --covarFile $covf \
  --strict \
  --phenoFile $phenof \
  --bsize 100 \
  --lowmem \
  --lowmem-prefix tmp_rg \
  --out ${outdir}/$fname

