
#-----------------------------
## filtering genotype data ##
#-----------------------------

plink=plink
MAF=0.05
MISS_SAMPLE=0.1
MISS_LOCUS=0.05
THINNING=0.75

$plink --file data/pigs --geno $MISS_LOCUS --mind $MISS_SAMPLE --maf $MAF --thin $THINNING --recode --out pigs_filtered


