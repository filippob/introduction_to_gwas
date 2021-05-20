
## phenotype data
scp -i GWAS2019.pem ubuntu@52.35.196.66:/home/ubuntu/filippo/introduction_to_gwas/data/rice_phenotypes.txt introduction_to_gwas/data/
scp -i GWAS2019.pem ubuntu@52.35.196.66:/home/ubuntu/filippo/introduction_to_gwas/data/dogs_phenotypes.txt introduction_to_gwas/data/

## imputed .raw files
scp -i GWAS2019.pem ubuntu@52.35.196.66:/home/ubuntu/filippo/introduction_to_gwas/3.imputation/rice_imputed.raw introduction_to_gwas/3.imputation/
scp -i GWAS2019.pem ubuntu@52.35.196.66:/home/ubuntu/filippo/introduction_to_gwas/3.imputation/dogs_imputed.raw introduction_to_gwas/3.imputation/

## imputed .map files
scp -i GWAS2019.pem ubuntu@52.35.196.66:/home/ubuntu/filippo/introduction_to_gwas/3.imputation/rice_imputed.map introduction_to_gwas/3.imputation/
scp -i GWAS2019.pem ubuntu@52.35.196.66:/home/ubuntu/filippo/introduction_to_gwas/3.imputation/dogs_imputed.map introduction_to_gwas/3.imputation/

## imputed plink binary files
scp -i GWAS2019.pem ubuntu@52.35.196.66:/home/ubuntu/filippo/introduction_to_gwas/3.imputation/rice_imputed.bed introduction_to_gwas/3.imputation/
scp -i GWAS2019.pem ubuntu@52.35.196.66:/home/ubuntu/filippo/introduction_to_gwas/3.imputation/rice_imputed.bim introduction_to_gwas/3.imputation/
scp -i GWAS2019.pem ubuntu@52.35.196.66:/home/ubuntu/filippo/introduction_to_gwas/3.imputation/rice_imputed.fam introduction_to_gwas/3.imputation/

scp -i GWAS2019.pem ubuntu@52.35.196.66:/home/ubuntu/filippo/introduction_to_gwas/3.imputation/dogs_imputed.bed introduction_to_gwas/3.imputation/
scp -i GWAS2019.pem ubuntu@52.35.196.66:/home/ubuntu/filippo/introduction_to_gwas/3.imputation/dogs_imputed.bim introduction_to_gwas/3.imputation/
scp -i GWAS2019.pem ubuntu@52.35.196.66:/home/ubuntu/filippo/introduction_to_gwas/3.imputation/dogs_imputed.fam introduction_to_gwas/3.imputation/

## software (in case you don't already have it)
scp -i GWAS2019.pem ubuntu@52.35.196.66:/home/ubuntu/filippo/introduction_to_gwas/software/GWASfunction.R introduction_to_gwas/software/
