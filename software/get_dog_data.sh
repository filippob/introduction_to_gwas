#!/bin/bash
###################################
## DOG DATA (binary)
###################################

## set resources
#plink=/home/filippo/Downloads/plink  # directory with plink binary
plink=plink  # directory with plink binary

## Download data

echo "Downloading dog data ..."

### Check for dir, if not found create it using the mkdir ##
[ ! -d "data" ] && mkdir -p "data"  # mkdir = make directory called data in relative path ".."

cd data

wget http://www.jackdellequerce.com/data/UCD_2014.tfam
wget http://www.jackdellequerce.com/data/UCD_2014.tped
#wget https://datadryad.org/bitstream/handle/10255/dryad.77584/UCD_2014.tfam
#wget https://datadryad.org/bitstream/handle/10255/dryad.77585/UCD_2014.tped

## prep phenotypes
Rscript --vanilla ../software/prep_dogpheno.R UCD_2014.tfam

## subset genotypes
$plink --dog --tfile UCD_2014 --chr 25,26,27,28,29 --recode --out dogs

echo "DONE!"
