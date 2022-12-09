#!/bin/bash
#########################
## REGENIE - step 2
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
step1res="rice_regenie_res_pred.list"

$regenie \
  --step 2 \
  --bed ${genotypef} \
  --covarFile $covf \
  --strict \
  --phenoFile $phenof \
  --bsize 100 \
  --firth --approx \
  --pThresh 0.05 \
  --pred $outdir/$step1res \
  --lowmem \
  --lowmem-prefix tmp_rg \
  --out ${outdir}/$fname


echo " - making plots of results"
Rscript plot_results.R $outdir/rice_regenie_res_Y1.regenie

echo "DONE!"
