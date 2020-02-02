#!/bin/bash
#############################################
## data handling
#############################################

plink=/home/filippo/Downloads/plink

## basic Plink commands

cd ../data
$plink --dog --file dogs --recode vcf --out dogs
$plink --dog --file dogs --recode vcf-iid --out dogs

## basic vcftools commands
#$vcftools --vcf dogs.vcf --plink --out dogs_plink

## exercise: try out the basic commands with the rice dataset, too

cd ../2.pre-processing

#################
## EDA
#################

#---------------------
## explore_genotypes:
#---------------------

## allele frequency

$plink --file ../data/rice --freq --out rice
$plink --file ../data/rice --freq counts --out rice
$plink --file ../data/rice --freqx --out rice

$plink --dog --file ../data/dogs --freq --out dogs
$plink --dog --file ../data/dogs --freq counts --out dogs
$plink --dog --file ../data/dogs --freqx --out dogs


## stratified allele frequencies

$plink --file ../data/rice --update-ids update.ids --recode --out rice_pop
$plink --file rice_pop --freq --family --out rice_pop ## frequency by population
$plink --dog --file ../data/dogs --freq case-control --allow-no-sex --out dogs


## missing rate

$plink --file ../data/rice --missing --out rice
$plink --dog --file ../data/dogs --missing --out dogs

## Hardy-Weinberg equilibrium

$plink --file ../data/rice --hardy --out rice
$plink --dog --file ../data/dogs --hardy --out dogs

$plink --file ../data/rice --het --out rice


## summarise genotype stats

# - <rstudio> eda.R ## EDA
# - <rstudio> hwe.R ## demonstration on HWE testing


#----------------------
## explore_phenotypes:
#----------------------

# - <rstudio> phenotypes.R ## EDA
# - <rstudio> phenotypes.Rmd ## markdown report
