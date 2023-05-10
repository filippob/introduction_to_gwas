
library("tidyverse")
library("data.table")

basefolder = "/home/filippo/Dropbox/cursos/gwas_2023"
prjfolder = "introduction_to_gwas"
genotype_file = file.path(basefolder, prjfolder, "example_data/rice_reduced.raw")
mapfile = file.path(basefolder, prjfolder, "example_data/rice_reduced.map")
outdir = file.path(basefolder, prjfolder, "2.pre-processing")

max_missing_snp = 0.05
max_missing_sample = 0.10
min_maf = 0.05

genotypes = fread(genotype_file)
snpmap = fread(mapfile)

matx = genotypes[,-c(1:6)]
N = nrow(matx)
m = ncol(matx)

### Missing rate per sample
missing_sample = rowSums(is.na(matx))
hist(missing_sample)
summary(missing_sample)

missing_rate_sample = missing_sample/m
summary(missing_rate_sample)

vec <- missing_rate_sample > max_missing_sample
print(paste(sum(vec), "samples are above the max missing threshold of", max_missing_sample))

## removing samples with excess missing rate
writeLines(" - removing samples with missing rate above threshold")
matx <- matx[!vec,]

## subset fam data accordingly
temp <- genotypes[!vec,c(1:6)]

### Missing rate per SNP
missing_snp = colSums(is.na(matx))
hist(missing_snp)
summary(missing_snp)

missing_rate_snp = missing_snp/N
summary(missing_rate_snp)

vec <- missing_rate_snp > max_missing_snp
print(paste(sum(vec), "SNPs are above the max missing threshold of", max_missing_snp))

## removing SNPs with excess missing rate
writeLines(" - removing SNPs with missing rate above threshold")
matx = matx[,!vec,with=FALSE]

## removing also from the map file
snpmap = snpmap[!vec,]

## MAF
nBB = colSums(matx == 2, na.rm = TRUE)
nAB = colSums(matx == 1, na.rm = TRUE)
nAA = colSums(matx == 0, na.rm = TRUE)

maf = ((2*nBB)+nAB)/(2*(nBB+nAB+nAA))
hist(maf)
summary(maf)

vec = maf >= min_maf
print(paste(sum(!vec), "SNPs are below the min MAF threshold of", min_maf))

## removing SNPs with low frequency
writeLines(" - removing SNPs with MAF below threshold")
matx = matx[,vec,with=FALSE]

## removing also from the map file
snpmap = snpmap[vec,]

## WRITE OUT FILTERED FILES
writeLines(" - writing out filtered files")

## map file
fname = file.path(outdir, "rice_reduced_filtered.map")
print(paste("writing map file to", fname))
fwrite(x = snpmap, file = fname, row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\t")

## map file
matx <- temp |> bind_cols(matx)
fname = file.path(outdir, "rice_reduced_filtered.raw")
print(paste("writing raw file to", fname))
fwrite(x = matx, file = fname, row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\t", na = NA)

print("DONE!")

