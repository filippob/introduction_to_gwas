
#-----------------------------
## filtering genotype data ##
#-----------------------------

plink=/home/filippo/Downloads/plink

$plink --file ../data/rice --geno 0.05 --mind 0.2 --maf 0.05 --recode --out rice_filtered
$plink --file ../data/dogs --dog --geno 0.05 --mind 0.2 --maf 0.05 --recode --out dogs_filtered


