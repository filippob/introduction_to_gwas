#!/bin/bash

outdir="rice"
genotypef="$outdir/rice_gemma"
covf="$outdir/covariates.txt"
kinship="$outdir/kinship.cXX.txt"
fname="res"

echo " - creating output folder"
## make output folder if it does not exist
if [ ! -d "${outdir}" ]; then
	mkdir -p ${outdir}
	chmod g+rxw ${outdir}
fi


## To calculate a centered relatedness matrix:
echo " - running GEMMA"
echo " - lmm 2: option 2) means LRT is performed for p-values"
gemma -bfile $genotypef -k $kinship -c $covff -lmm 2 -outdir $outdir -o $fname

echo " - making plots"
Rscript --vanilla support_scripts/plot_results.R ${outdir}/${fname}.assoc.txt

## cleaning the working space
rm $outdir/*.log.* $outdir/ids.keep $outdir/upd_pheno

echo "DONE!"
