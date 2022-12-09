#!/bin/bash
###################################
## PIG DATA (binary)
###################################

## set resources
plink=plink
#plink=/home/filippo/Downloads/plink  # directory with plink binary

## Download data (rice, continuous)
echo "Downloading pigs data ..."

### Check for dir, if not found create it using the mkdir ##
[ ! -d "data" ] && mkdir -p "data"  # mkdir = make directory called data in relative path ".."

cd data
  
wget http://www.jackdellequerce.com/data/GWAS_cohort.tar.gz  # wget - retrieve content from web servers

