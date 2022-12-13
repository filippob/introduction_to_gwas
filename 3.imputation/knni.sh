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
$plink --dog --file ../2.pre-processing/dogs_filtered --chr 25 --thin 0.025 --recode --out dogs_chr25

# make the matrix of Hamming distances
Rscript --vanilla hamming.R dogs_chr25.ped

# run imputation
Rscript --vanilla knni.R dogs_chr25.ped
