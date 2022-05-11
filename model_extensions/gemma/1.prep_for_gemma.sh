#!/bin/bash

plink="$HOME/Downloads/plink"
outdir="rice"
genotypef="../../6.steps/rice_imputed"
phenotypef="../../6.steps/data/rice_phenotypes.txt"
fid="NF1"
fname="rice_gemma"
species="rice"

## make output folder if it does not exist
if [ ! -d "${outdir}" ]; then
	echo " - creating output folder"
	mkdir -p ${outdir}
	chmod g+rxw ${outdir}
fi


echo " - preparing the file with phnotype info to be fed to Plink"
## use awk to add a constant column to the phenotype file and select relevant columns
## $1: IID; $3: phenotype (plant height)
tail -n +2 $phenotypef > $outdir/temp 
awk -v FID=$fid '{print FID,$1,$3}' $outdir/temp > $outdir/upd_pheno
rm $outdir/temp

echo " - generating the binary Plink files with phenotype information"
$plink --$species --file $genotypef --pheno $outdir/upd_pheno --make-bed --out $outdir/$fname

echo " - extracting IDs from the imputed ped file"
cut -f1-2 -d' ' ${genotypef}.ped > $outdir/ids.keep

echo " - preparing the covariates file"
Rscript --vanilla support_scripts/prep_covs_for_gemma.R $phenotypef $outdir/ids.keep

## house cleaning
rm $outdir/*.hh $outdir/*.nosex $outdir/*.log

echo "DONE!"

