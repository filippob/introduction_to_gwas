#!/bin/bash
###################################
## RICE DATA (continuous)
###################################

## set resources
plink=/home/filippo/Downloads/plink  # directory with plink binary
#plink=plink  # directory with plink binary
trait=PH

## Download data (rice, continuous)
echo "Downloading rice data ..."

### Check for dir, if not found create it using the mkdir ##
[ ! -d "data" ] && mkdir -p "data"  # mkdir = make directory called data in relative path ".."

cd data

wget https://zenodo.org/record/50803/files/GBSgenotypes.tar.gz   # wget - retrieve content from web servers
wget https://zenodo.org/record/50803/files/plantgrainPhenotypes.txt

tar -xvzf GBSgenotypes.tar.gz  # extract files from archive

wc -l GBSnew.ped # wc = word count, -l = count lines: Number of genotypes in ped file
wc -l GBSnew.map # Number of markers in map file

wc -l plantgrainPhenotypes.txt # Number of phenotypic records
#less -S plantgrainPhenotypes.txt

## retrieve group information
## create new phenotypes file and ids file for Plink subsetting
## Run R script "prep_rice_data.R" from terminal and submit the arguments "plantgrainPhenotypes.txt", "rice_group.reference" and "PH" to the script 
Rscript ../software/prep_rice_data_pipeline.R plantgrainPhenotypes.txt ../software/rice_group.reference $trait


## this is to match ids between files
sed -i 's/\_//g' GBSnew.ped 
sed -i 's/a//g' GBSnew.ped

## use Plink to subset data
$plink --file GBSnew --keep ids --chr 1,2,6,7 --recode --out rice

rm rice.log rice.nosex  # remove log-file generated by plink
