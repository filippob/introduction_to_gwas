#--------------------------------------
## imputation of missing genotypes  ##
#--------------------------------------

## set paths to executables
plink=/home/filippo/Downloads/plink
beagle=/home/filippo/Documents/beagle4.1/beagle.27Jan18.7e1.jar

## convert to vcf
$plink --file rice_filtered --recode vcf --out rice_filtered

$plink --dog --file dogs_filtered --recode vcf --out dogs_filtered	## check the warning on underscores !!
$plink --dog --file dogs_filtered --recode vcf-iid --out dogs_filtered

## Beagle
if [ $beagle = beagle ]; then
	beagle gt=rice_filtered.vcf out=rice_imputed
	beagle gt=dogs_filtered.vcf out=dogs_imputed
else
	java -Xss5m -Xmx4g -jar $beagle gt=rice_filtered.vcf out=rice_imputed
        java -Xss5m -Xmx4g -jar $beagle gt=dogs_filtered.vcf out=dogs_imputed
fi

beagle gt=rice_filtered.vcf out=rice_imputed
beagle gt=dogs_filtered.vcf out=dogs_imputed

## convert back to ped/map
$plink --vcf rice_imputed.vcf.gz --recode --out rice_imputed
$plink --dog --vcf dogs_imputed.vcf.gz --recode --out dogs_imputed

echo "DONE!"
