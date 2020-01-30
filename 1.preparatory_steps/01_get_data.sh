#!/bin/bash
###################################
## RICE DATA (continuous)
###################################

## set resources
plink=/home/filippo/Downloads/plink

## Download data (rice, continuous)

### Check for dir, if not found create it using the mkdir ##
[ ! -d "../data" ] && mkdir -p "../data"

cd ../data

wget https://zenodo.org/record/50803/files/GBSgenotypes.tar.gz
wget https://zenodo.org/record/50803/files/plantgrainPhenotypes.txt

tar -xvzf GBSgenotypes.tar.gz

wc -l GBSnew.ped
wc -l GBSnew.map

wc -l plantgrainPhenotypes.txt
#less -S plantgrainPhenotypes.txt

## retrieve group information
## create new phenotypes file and ids file for Plink subsetting
Rscript ../1.preparatory_steps/prep_rice_data.R plantgrainPhenotypes.txt ../cross_reference/rice_group.reference PH

wc -l rice_phenotypes.txt
#less rice_phenotypes.txt

wc -l ids
#less ids


## this is to match ids between files
sed -i 's/\_//g' GBSnew.ped 
sed -i 's/a//g' GBSnew.ped

## use Plink to subset data
$plink --file GBSnew --keep ids --chr 1,2,6,7 --recode --out rice

rm rice.log rice.nosex

###################################
## DOG DATA (binary)
###################################

## Download data
wget http://www.jackdellequerce.com/data/UCD_2014.tfam
wget http://www.jackdellequerce.com/data/UCD_2014.tped
#wget https://datadryad.org/bitstream/handle/10255/dryad.77584/UCD_2014.tfam
#wget https://datadryad.org/bitstream/handle/10255/dryad.77585/UCD_2014.tped

## prep phenotypes
Rscript --vanilla ../1.preparatory_steps/prep_dogpheno.R UCD_2014.tfam

## subset genotypes
$plink --dog --tfile UCD_2014 --chr 25,26,27,28,29 --recode --out dogs

echo "DONE!"
