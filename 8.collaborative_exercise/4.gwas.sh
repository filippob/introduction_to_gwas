#----------
## GWAS ##
#----------

plink=plink

## prepare data for gwas.R
$plink --file pigs_imputed --recode A --out pigs_imputed


## GWAS
Rscript --vanilla ../introduction_to_gwas/4.gwas/gwas_statgengwas.R genotype_file=pigs_imputed.raw snp_map=pigs_imputed.map phenotype_file=data/pigs_phenotypes.txt trait=phenotype trait_label=stmp_tail


