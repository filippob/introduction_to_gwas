#!/bin/bash
###################################
## PIG DATA (binary)
###################################

## set resources
# plink=plink
plink=/home/filippo/Downloads/plink  # directory with plink binary

## Download data (rice, continuous)
echo "Downloading pigs data ..."

### Check for dir, if not found create it using the mkdir ##
[ ! -d "data" ] && mkdir -p "data"  # mkdir = make directory called data in relative path ".."

cd data

wget https://zenodo.org/record/4081475/files/raw_data.tar.gz   # wget - retrieve content from web servers

tar -xvzf raw_data.tar.gz  # extract files from archive

wc -l raw_data/plink_binaries/GWAS_cohort.fam # wc = word count, -l = count lines: Number of genotypes in ped file
$plink --bfile raw_data/plink_binaries/GWAS_cohort --freq --out raw_data/freq
wc -l raw_data/freq.frq  # Number of markers in map file

wc -l raw_data/pheno # Number of phenotypic records

## use Plink to subset data
$plink --bfile raw_data/plink_binaries/GWAS_cohort --chr 10,11,12,13,14 --recode --out pigs
rm pigs.log pigs.nosex  # remove log-file generated by plink

## move up one level
cd ..

## introduce artificially missing SNP genotypes (for imputation)
echo "introducing missing"
Rscript ../software/injectMissing.R data/pigs.ped 0.01 data/pigs.ped
# cp data/pigs.map pigs_missing.map
$plink --file data/pigs --missing --out pigs
avg_miss_rate=`awk '{ total += $6; count++ } END { print total/count }' pigs.imiss`

## preprocess phenotypic data
echo -e "fam id phenotype" | cat - data/raw_data/pheno | awk '{print $2,$1,$3}' > data/pigs_phenotypes.txt

## clean repo
rm pigs.imiss pigs.lmiss pigs.log pigs.nosex 
rm data/raw_data.tar.gz
rm -r data/raw_data

echo "Average missing rate is ${avg_miss_rate}"
echo "DONE!"