#!/bin/bash
###################################
## PIG DATA (binary)
###################################

## set resources
# plink=plink
plink=~/Downloads/plink

## Download pig data
## download from: http://www.jackdellequerce.com/data/GWAS_cohort.tar.gz
echo "Downloading pigs data ..."

### Check for dir, if not found create it using the mkdir ##
[ ! -d "data" ] && mkdir -p "data"  # mkdir = make directory called data in relative path ".."

cd data

wget http://www.jackdellequerce.com/data/GWAS_cohort.tar.gz

tar -xvzf GWAS_cohort.tar.gz

#create ped and map files
$plink --bfile GWAS_cohort --recode --tab --out GWAS_cohort

#remove underscore from ped file
sed -i 's/\_//g' GWAS_cohort.ped

#subset original ped and map files
$plink --file GWAS_cohort --chr 10,11,12 --double-id --recode --out pigs


### YOUR CODE HERE !! ###


echo "DONE!"


