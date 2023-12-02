#!/bin/bash
###################################
## PIG DATA (binary)
###################################

## set resources
plink=plink

## Download pig data
## download from: http://www.jackdellequerce.com/data/GWAS_cohort.tar.gz
echo "Downloading pigs data ..."

### Check for dir, if not found create it using the mkdir ##
[ ! -d "data" ] && mkdir -p "data"  # mkdir = make directory called data in relative path ".."

cd data

### YOUR CODE HERE !! ###

# download data
# uncompress
# recode/rename (if needed)
# manipulate/preprocess if needed


echo "DONE!"


