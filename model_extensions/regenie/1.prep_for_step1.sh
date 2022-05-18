#!/bin/bash

plink="$HOME/Downloads/plink"
genotypef="../../6.steps/rice_imputed"
phenotypef="../../6.steps/data/rice_phenotypes.txt"
groupref="../../cross_reference/rice_group.reference"
fid="NF1"
outdir="rice"
fname="rice_regenie"
species="rice"
pcaf=${outdir}/${fname}.eigenvec

## make output folder if it does not exist
if [ ! -d "${outdir}" ]; then
	echo " - creating output folder"
	mkdir -p ${outdir}
	chmod g+rxw ${outdir}
fi

echo " - generating the binary Plink files"
$plink --$species --file $genotypef --make-bed --out $outdir/$fname

echo " - preparingthe phenotype file"
awk -v FID=$fid '{print FID, $1, $3}'  ${phenotypef} > $outdir/phenotypes.tsv
sed -i 's/id/IID/g' $outdir/phenotypes.tsv
sed -i 's/PH/Y1/g' $outdir/phenotypes.tsv
sed -i 's/ /\t/g' $outdir/phenotypes.tsv

echo " - preparing the covariates file"
$plink --file $genotypef --pca 4 --out $outdir/$fname
Rscript --vanilla prep_covs.R ${outdir}/phenotypes.tsv $groupref ${genotypef}.fam $pcaf

## house cleaning
rm $outdir/*.hh $outdir/*.nosex $outdir/*.log $outdir/*eigen*

echo "DONE!"

