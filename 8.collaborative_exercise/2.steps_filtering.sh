
#-----------------------------
## filtering genotype data ##
#-----------------------------

## PARAMETERS
plink=plink

## YOUR CODE HERE
$plink --file data/pigs --geno 0.05 --mind 0.2 --maf 0.05 --recode --out pigs_filtered
#3849 variants
#106 individuals

echo "DONE!"
