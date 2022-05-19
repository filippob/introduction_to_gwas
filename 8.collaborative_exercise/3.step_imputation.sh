#--------------------------------------
## imputation of missing genotypes  ##
#--------------------------------------

## set paths to executables
plink=plink
beagle=beagle
#beagle=/home/filippo/Documents/software/beagle5/beagle.28Sep18.793.jar

## convert to vcf
$plink --file pigs_filtered --recode vcf-iid --out pigs_filtered

## Beagle
if [ $beagle = beagle ]; then
	beagle gt=pigs_filtered.vcf out=pigs_imputed
else
	java -Xss5m -Xmx4g -jar $beagle gt=pigs_filtered.vcf out=pigs_imputed
fi

## convert back to ped/map
$plink --vcf pigs_imputed.vcf.gz --recode --double-id --out pigs_imputed

rm pigs_imputed.vcf.gz

echo "DONE!"
