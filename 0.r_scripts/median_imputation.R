
library("tidyverse")
library("data.table")

prjfolder = "~/Dropbox/cursos/gwas_2024"
repo = "introduction_to_gwas"

## PARAMETERS
genotypes_file = "example_data/rice_filtered.raw"
map_file = "example_data/rice_filtered.map"

## READ DATA
fname = file.path(prjfolder, repo, genotypes_file)
genotypes = fread(fname)

fname = file.path(prjfolder, repo, map_file)
snpmap = fread(fname)

matx = as.data.frame(genotypes[,-c(1:6)])
metadata = genotypes[,c(1:6)]

## MEDIAN IMPUTATION
meds <- matx |>
  summarise(across(everything(), \(x) median(x, na.rm=TRUE))) |>
  gather(key = "snp", value = "median") |>
  pull(median)

for (i in 1:ncol(matx)) {
  
  print(paste("imputing SNP n.", i, "with name", names(matx)[i]))
  matx[,i][is.na(matx[,i])] <- meds[i]
}

print("sanity check")
print(summary(colSums(is.na(matx))))

## in case some loci are left unimputed
vec <- colSums(is.na(matx)) > 0
matx <- matx[,!vec]

###################
## write out files
###################

## genotype file
genotypes = metadata |> bind_cols(matx)

## map file
snpnames = gsub("_[A-Z0-9]{1}$","",names(matx))
vec <- (snpmap$V2 %in% snpnames)
snpmap <- snpmap[vec,]

fname = file.path(prjfolder, repo, "example_data/rice_median_imputed.raw")
fwrite(x = genotypes, file = fname, quote = FALSE, sep = " ", na = "NA")


fname = file.path(prjfolder, repo, "example_data/rice_median_imputed.map")
fwrite(x = snpmap, file = fname, quote = FALSE, sep = "\t", col.names = FALSE)

print("DONE!")
