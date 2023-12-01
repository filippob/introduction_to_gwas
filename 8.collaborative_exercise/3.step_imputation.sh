#--------------------------------------
## imputation of missing genotypes  ##
#--------------------------------------

## set paths to executables
## PARAMETERS
plink=plink
#plink=~/Downloads/plink
beagle=beagle
#beagle=~/Documents/software/beagle5/beagle.28Sep18.793.jar

## YOUR CODE HERE
#Imputation
$plink --file pigs_filtered --recode vcf --out pigs_filtered

if [ $beagle = beagle ]; then
	beagle gt=pigs_filtered.vcf out=pigs_imputed
else
	java -Xmx4g -jar $beagle gt=pigs_filtered.vcf out=pigs_imputed
fi

$plink  --vcf pigs_imputed.vcf.gz --recode --out pigs_imputed

#create raw file
$plink --file pigs_imputed  --recode A --out pigs_imputed

## COMMAND LINES

