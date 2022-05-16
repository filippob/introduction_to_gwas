## run as: Rscript --vanilla retrieve_data.R plantgrainPhenotypes.txt rice_group.reference PH

########## - SET UP - ###############
library("tidyverse")
library("data.table")

# -------------------------------------
# Reading File 1, and creating the subsets df and df.red
# -------------------------------------
## read from command line
args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
}


# Assign the arguments passed on from the bash script
phenotype_file = args[1]
print(paste("phenotype file name:",phenotype_file))
group_reference_file = args[2]
print(paste("rice groups reference file:",group_reference_file))
fam_file = args[3]
print(paste("rice groups reference file:",group_reference_file))
pcaf = args[4]
print(paste("pca file:", pcaf))

# phenotype_file = "extensions/regenie/rice/phenotypes.tsv"
# group_reference_file = "introduction_to_gwas/cross_reference/rice_group.reference"
# fam_file = "extensions/regenie/rice/rice_regenie.fam"
# pcaf = "extensions/regenie/rice/rice_regenie.eigenvec"

pheno = fread(phenotype_file)
ref_file = fread(group_reference_file)
fam = fread(fam_file)
pca = fread(pcaf)

## phenotypes
pheno = rename(pheno, FID = NF1)
pheno = pheno[pheno$IID %in% fam$V2,]
fwrite(x = pheno, file = phenotype_file, sep = "\t")

## covariates
npcs = ncol(pca)-2
names(pca) <- c("FID", "IID", paste("PC", seq(1,npcs), sep=""))

pheno$pop <- ref_file$population[match(pheno$IID, ref_file$id)]
pheno$population <- model.matrix(~pop, pheno)[,2]

covs = select(pheno, c(FID, IID, population))
covs = covs %>% inner_join(select(pca, -FID), by = "IID")

fname = file.path(dirname(phenotype_file), "covariates.tsv")
fwrite(x = covs, file = fname, sep = "\t")

