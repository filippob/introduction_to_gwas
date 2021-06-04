## R script to carry out KNN imputation using tidymodels
## kinship matrix used to account for population structure in the data
## input: Plink .raw file (matrix of 0s, 1s, 2s)
# run as Rscript --vanilla knni.R genotype_file=path_to_genotypes k=k

library("tidymodels") #for kNN imputation
library("data.table")

print("KNN imputation of missing genotypes")

###################################
## read arguments from command line
###################################
allowed_parameters = c(
  'genotype_file',
  'k'
)

args <- commandArgs(trailingOnly = TRUE)

print(args)
for (p in args){
  pieces = strsplit(p, '=')[[1]]
  #sanity check for something=somethingElse
  if (length(pieces) != 2){
    stop(paste('badly formatted parameter:', p))
  }
  if (pieces[1] %in% allowed_parameters)  {
    assign(pieces[1], pieces[2])
    next
  }
  
  #if we get here, is an unknown parameter
  stop(paste('bad parameter:', pieces[1]))
}

print("READING DATA ...")
# genotype_file = "introduction_to_gwas/3.imputation/dogs_chr25.raw"
# k = 3

print(paste("genotype file name:",genotype_file))
print(paste("K:",k))

geno = fread(genotype_file)
matx = geno[,-c(1:6)]
fam <- geno[,c(1:6)]
rm(geno)

print(paste("N. of missing SNP genotypes to be imputed:",sum(is.na(matx))))

### imputation
print("IMPUTATION ...")
rec <- recipe(matx) %>% 
  update_role(all_numeric(), new_role = "predictor")

ratio_recipe <- rec %>%
  step_impute_knn(all_predictors(), neighbors = k)

ratio_recipe2 <- prep(ratio_recipe, training = matx, verbose = FALSE)
imputed = juice(ratio_recipe2)
# imputed2 = bake(ratio_recipe2, matx)

print(paste("N. of missing SNP genotypes to be imputed:",sum(is.na(imputed))))
imputed <- fam %>% bind_cols(imputed)

## try out different k values
print("WRITING OUT RESULTS ...")
fname  <- paste(gsub("\\..*$","",basename(genotype_file)),"_imputed.raw", sep="")
fwrite(imputed, file=fname, sep = "\t")

print("DONE!")

