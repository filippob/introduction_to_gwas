
library("tidyverse")
library("data.table")

prjfolder = "~/Dropbox/cursos/gwas_2023"
repo = "introduction_to_gwas"

## PARAMETERS
genotypes_file = "example_data/rice_reduced.raw"
map_file = "example_data/rice_reduced.map"
snp_threshold = 0.10 ## max missing rate allowed per SNP
sample_threshold = 0.20
maf_threshold = 0.025 ## min allowed MAF

fname = file.path(prjfolder, repo, genotypes_file)
genotypes = fread(fname)

fname = file.path(prjfolder, repo, map_file)
snpmap = fread(fname)

matx = genotypes[,-c(1:6)]
metadata = genotypes[,c(1:6)]

## MISSING RATE
snp_missing_rate = colSums(is.na(matx))/nrow(matx)
print(summary(snp_missing_rate))
hist(snp_missing_rate)

vec <- snp_missing_rate > snp_threshold
print(paste("% of SNPs with missing rate larger than", snp_threshold, "that will be removed", round(100*(sum(vec)/ncol(matx)),2), "%"))

matx = matx[, !vec, with=FALSE]      

sample_missing_rate = rowSums(is.na(matx))/ncol(matx)
print(summary(sample_missing_rate))
hist(sample_missing_rate)

vec <- sample_missing_rate > sample_threshold
print(paste("% of samples with missing rate larger than", sample_threshold, "that will be removed", round(100*(sum(vec)/nrow(matx)),2), "%"))

matx = matx[!vec,]
metadata = metadata[!vec,]

##MAF
aa = colSums(matx == 0, na.rm = TRUE)
summary(aa)

ab = colSums(matx == 1, na.rm = TRUE)
summary(ab)

alleles = (2*aa + ab)
maf = 1-alleles/(2*nrow(matx))

summary(maf)
hist(maf)

vec <- maf >= maf_threshold
print(paste("% of SNPs with MAF larger than", maf_threshold, "that will NOT be removed", round(100*(sum(vec)/ncol(matx)),2), "%"))

matx = matx[, vec, with=FALSE]

###################
## write out files
###################

## genotype file
genotypes = metadata |> bind_cols(matx)

## map file
snpnames = gsub("_[A-Z0-9]{1}$","",names(matx))
vec <- (snpmap$V2 %in% snpnames)
snpmap <- snpmap[vec,]

fname = file.path(prjfolder, repo, "example_data/rice_filtered.raw")
fwrite(x = genotypes, file = fname, quote = FALSE, sep = " ", na = "NA")


fname = file.path(prjfolder, repo, "example_data/rice_filtered.map")
fwrite(x = snpmap, file = fname, quote = FALSE, sep = "\t", col.names = FALSE)
