#!/bin/bash
##################
## KNNI imputation
##################
## Demonstration

#<rstudio> knni.Rmd

## command lines (and instruction) for data filtering, imputation and preparation (for GWAS)
#plink=/home/filippo/Downloads/plink
plink=plink ## path to plink

# subset data
echo " - subsetting the data"
$plink --dog --file ../2.pre-processing/dogs_filtered --chr 25 --thin 0.025 --recode --out dogs_chr25

# make the matrix of Hamming distances
echo " - calculating Hamming distances"
Rscript --vanilla hamming.R dogs_chr25.ped

# create the configuration file
echo " - creating the configuration file for imputation"
touch config.r
echo "config = data.frame(input_data = 'dogs_chr25.ped', k = 3)" > config.r

# run imputation
echo " - running KNN imputation"
Rscript --vanilla knni.R config.r

echo "DONE!"
