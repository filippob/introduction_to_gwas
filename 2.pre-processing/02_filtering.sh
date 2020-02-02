#!/bin/bash
#########################
## DATA FILTERING
#########################

## command lines (and instruction) for data filtering, imputation and preparation (for GWAS)
plink=/home/filippo/Downloads/plink
beagle=/home/filippo/Documents/beagle4.1/beagle.27Jan18.7e1.jar

## filtering genotype data
$plink --file ../data/rice --geno 0.05 --mind 0.2 --maf 0.05 --recode --out rice_filtered
$plink --dog --file ../data/dogs --geno 0.05 --mind 0.2 --maf 0.05 --recode --out dogs_filtered


