#!/bin/bash

plink="$HOME/Downloads/plink"
genotypef="../../6.steps/rice_imputed"
phenotypef="../../6.steps/data/rice_phenotypes.txt"
fid="NF1"
outdir="rice"
fname="rice_blink"
species="rice"

## make output folder if it does not exist
if [ ! -d "${outdir}" ]; then
	echo " - creating output folder"
	mkdir -p ${outdir}
	chmod g+rxw ${outdir}
fi


echo " - generating the binary Plink files with phenotype information"
$plink --$species --file $genotypef --recode A-transpose --out $outdir/$fname
cut -f7- $outdir/${fname}.traw > $outdir/temp
tail -n +2 $outdir/temp > $outdir/${fname}.mat
#sed -i 's/ /\t/g' $outdir/${fname}.mat

echo " - extracting IDs from the imputed ped file"
cut -f1-2 -d' ' ${genotypef}.ped > $outdir/ids.keep

echo " - preparing the map file with SNP name, chrom and pos"
awk '{print $2, $1, $4}' ${genotypef}.map > $outdir/${fname}.map
sed -i '1i rs chr pos' $outdir/${fname}.map
sed -i 's/ /\t/g' $outdir/${fname}.map

echo " - preparing the covariates file"
Rscript --vanilla prep_pheno_and_covs_for_blink.R $phenotypef $outdir/ids.keep

## house cleaning
rm $outdir/*.hh $outdir/*.nosex $outdir/*.log $outdir/*.traw $outdir/temp

echo "DONE!"

