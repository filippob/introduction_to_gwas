## R script to carry out a GWAS analysis with the package rrBLUP
## kinship matrix used to account for population structure in the data
## input: Plink .raw and .map files + phenotype file
# run as Rscript --vanilla gwas_sommer.R genotype_file=path_to_genotypes snp_map=path_to_map phenotype_file=path_to_phenotypes trait=trait_name_in_phenotype_file trait_label=label_to_use_for_trait

library("qqman")
library("sommer")
library("tidyverse")
library("data.table")

trim <- function (x) gsub("^\\s+|\\s+$", "", x)

print("GWAS using the sommer package")

###################################
## read arguments from command line
###################################
allowed_parameters = c(
  'genotype_file',
  'snp_map',
  'phenotype_file',
  'trait',
  'trait_label',
  'covariates'
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

# genotype_file = "introduction_to_gwas/3.imputation/rice_imputed.raw"
# snp_map = "introduction_to_gwas/3.imputation/rice_imputed.map"
# phenotype_file = "introduction_to_gwas/data/rice_phenotypes.txt"
# trait = "PH"
# trait_label = "plant_height"
# covariates="population"

print(paste("genotype file name:",genotype_file))
print(paste("SNP map:",snp_map))
print(paste("phenotype file name:",phenotype_file))
print(paste("trait:",trait))
print(paste("trait label:",trait_label))
covariates = if(exists(x = "covariates")) covariates else 1
print(paste("covariates:",covariates))

dataset = basename(genotype_file)

## READING DATA
print("now reading in the data ...")
### genotypes
snp_matrix <- fread(genotype_file, header = TRUE)
print(paste(nrow(snp_matrix),"records read from the genotype file",sep=" "))
SNP_INFO <- fread(snp_map)
names(SNP_INFO) <- c("Chrom","snp","cM","Position")
SNP_INFO$cM <- NULL

X <- as.matrix(snp_matrix[,-c(1:6)])
colnames(X) <- gsub("\\_[A-Z]{1}$","",colnames(X))
rownames(X) <- snp_matrix$IID

# SNP_INFO <- bind_cols(SNP_INFO,as.data.frame(t(X)))

print(paste(nrow(SNP_INFO),"SNPs read from the map file",sep=" "))

if ((ncol(snp_matrix)-6) != nrow(SNP_INFO)) {
  
  stop("!! N. of SNPs in the map file not equal to the number of genotyped SNPs in the genotype file")
  
} else print("N. of SNPs in the map and genotype files is the same: this is correct!!")

### phenotypes
phenotypes <- fread(phenotype_file)
# phenotypes <- phenotypes[,c(1,3)]
print(paste(nrow(phenotypes),"records read from the phenotype file",sep=" "))

phenotypes <- phenotypes[phenotypes$id %in% snp_matrix$IID,]
print(paste(nrow(phenotypes),"records read from the phenotype file after alignment with genotypes",sep=" "))

## kinship matrix
print("Calculating the kinship matrix")
K <-A.mat(X)

vec <- colnames(K) %in% phenotypes$id
K <- K[vec,vec]

# SNP_INFO <- as.data.frame(SNP_INFO)
# SNP_INFO <- SNP_INFO[,c(TRUE,TRUE,TRUE,vec)]

print("producing the heatmap kinship matrix ...")
pdf(paste(dataset,"_kinship_heatmap",".pdf",sep=""))
heatmap(K)
dev.off()

###################
## Running the GWAS
###################
phenotypes <- phenotypes %>% dplyr::rename(phenotype = !!as.name(trait))

fmod <- as.formula(
  paste("phenotype",
        gsub(",","+",covariates),
        sep = " ~ "))

mix_mod <- GWAS(fmod,
                random = ~vs(id, Gu=K),
                rcov = ~units,
                data = phenotypes,
                M = X,
                gTerm = "u:id", 
                verbose = TRUE)

###########
### RESULTS
###########
print("writing out results and figures ...")
ms <- as.data.frame(mix_mod$scores)
ms$snp <-gsub("_[A-Z]{1}$","",rownames(ms))

# convert -log(p) back to p-values
p <- 10^((-ms$phenotype))

mapf <-merge(SNP_INFO, ms, by="snp", all.x = TRUE);
mapf$pvalue <- p
mapf <- filter(mapf, phenotype < Inf)
png(paste(dataset,trait_label,"manhattan_sommer.png",sep="_"))
sommer::manhattan(mapf, pch=20,cex=.75, PVCN = "phenotype")
dev.off()

## rename P to log_p (as it is) and add the column with p-values
names(mapf)[4] <- "log_p"
fname <- paste(dataset,trait_label,"GWAS_sommer.results", sep="_")
fwrite(x = mapf, file = fname)

## qq-plot
png(paste(dataset,trait_label,"qqplot_sommer.png",sep="_"), width = 600, height = 600)
qqman::qq(mapf$pvalue)
dev.off()

print("#########")
print("## END ##")
print("#########")



