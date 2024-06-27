#!/bin/bash
###################################
## RICE DATA (continuous)
###################################

## Download data (rice, continuous)
echo "Downloading rice data ..."

### Check for dir, if not found create it using the mkdir ##
[ ! -d "../data" ] && mkdir -p "../data"  # mkdir = make directory called data in relative path ".."

cd ../data

wget https://zenodo.org/record/50803/files/GBSgenotypes.tar.gz   # wget - retrieve content from web servers
wget https://zenodo.org/record/50803/files/plantgrainPhenotypes.txt

tar -xvzf GBSgenotypes.tar.gz  # extract files from archive

wc -l GBSnew.ped # wc = word count, -l = count lines: Number of genotypes in ped file
wc -l GBSnew.map # Number of markers in map file

wc -l plantgrainPhenotypes.txt # Number of phenotypic records


###################################
## DOG DATA (binary)
###################################

## Download data

echo "Downloading dog data ..."

wget http://www.jackdellequerce.com/data/UCD_2014.tfam
wget http://www.jackdellequerce.com/data/UCD_2014.tped


echo "DONE!"
