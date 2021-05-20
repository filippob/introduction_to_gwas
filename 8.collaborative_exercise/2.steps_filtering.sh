
#-----------------------------
## filtering genotype data ##
#-----------------------------

plink=/home/filippo/Downloads/plink

$plink --file data/pigs --geno 0.05 --mind 0.1 --maf 0.05 --recode --out pigs_filtered


