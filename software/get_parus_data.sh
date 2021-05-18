#!/bin/sh
###################################
## PARUS DATA (continuous)
###################################

## set resources
#plink=/home/filippo/Downloads/plink  # directory with plink binary
plink=plink  # directory with plink binary

cd data

echo "Downloading Parus data ..."

wget http://www.jackdellequerce.com/data/doi_10.5061_dryad.ck1rq__v1.zip
unzip doi_10.5061_dryad.ck1rq__v1.zip

$plink --file 2497_indiv_5591_markers --chr-set 31 --chr 1,2,3 --bp-space 1 --recode --out parus

Rscript --vanilla ../software/prepare_parus_data.R 2497_indiv_phenotype.txt

echo "DONE!"


