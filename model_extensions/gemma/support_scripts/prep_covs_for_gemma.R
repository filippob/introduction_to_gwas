## Rscript to prepare the covariates file for GEMMA
## arguments: 1) phenotype file; 2) ids to keep
## https://github.com/genetics-statistics/GEMMA

# -------------------------------------
# Reading File 1
# -------------------------------------
## read from command line
args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
}

# phenotype_file = "../introduction_to_gwas/6.steps/data/rice_phenotypes.txt"
# idsf = "extensions/prova/ids.keep"
phenotype_file= args[1]
idsf= args[2]

print(paste("The phenotype file to be read is:", basename(phenotype_file)))
print(paste("The file with genotyped sample IDs is:", basename(idsf)))

### SET UP ###
library("here")
library("tidyverse")
library("data.table")

## READ DATA ##
# temp = unlist(strsplit(phenotype_file, split = "/")[[1]])
# path_to_file = here(paste(temp[temp != ".."], collapse = "/"))
# rice = fread(path_to_file)
rice = fread(phenotype_file)

# temp = unlist(strsplit(idsf, split = "/")[[1]])
# path_to_file = here(paste(temp[temp != ".."], collapse = "/"))
# ids = fread(path_to_file, header = FALSE)
ids = fread(idsf, header = FALSE)

## FILTER PHENOTYPES
rice = filter(rice, id %in% ids$V2)

## CREATE COVARIATES FILE
covariates = model.matrix(~population, data = select(rice, c(id,population)))

writeLines(" - writing out the covariates file")
# temp = unlist(strsplit(dirname(idsf), split = "/")[[1]])
# path_to_folder = here(paste(temp[temp != ".."], collapse = "/"))
path_to_folder = dirname(idsf)
fname = file.path(path_to_folder, "covariates.txt")
fwrite(x = covariates, file = fname, sep = "\t", col.names = FALSE)
