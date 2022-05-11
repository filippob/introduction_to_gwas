#!/bin/bash

## script to make the kinship matrix
## using GEMMA

outdir="rice"
genotypef="$outdir/rice_gemma"
covf="$outdir/covariates.txt"
fname="kinship"

echo " - creating output folder"
## make output folder if it does not exist
if [ ! -d "${outdir}" ]; then
	mkdir -p ${outdir}
	chmod g+rxw ${outdir}
fi


## To calculate a centered relatedness matrix:
echo " - running GEMMA"
gemma -bfile $genotypef -c $covff -miss 0.01 -maf 0.10 -r2 0.9 -gk -outdir $outdir -o $fname

echo "DONE!"
