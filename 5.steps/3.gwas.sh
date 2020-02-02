#----------
## GWAS ##
#----------

plink=/home/filippo/Downloads/plink

## prepare data for gwas.R
$plink --file rice_imputed --recode A --out rice_imputed
$plink --dog --file dogs_imputed --recode A --out dogs_imputed


## GWAS
Rscript --vanilla ../4.gwas/gwas.R genotype_file=rice_imputed.raw snp_map=rice_imputed.map phenotype_file=../data/rice_phenotypes.txt trait=PH trait_label=PH
Rscript --vanilla ../4.gwas/gwas.R genotype_file=dogs_imputed.raw snp_map=dogs_imputed.map phenotype_file=../data/dogs_phenotypes.txt trait=phenotype trait_label=cleft_lip


