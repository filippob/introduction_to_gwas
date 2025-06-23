## R script to carry out a GWAS analysis with the package rrBLUP
## kinship matrix used to account for population structure in the data
## input: Plink .raw and .map files + phenotype file
# run as Rscript --vanilla gwas_sommer.R genotype_file=path_to_genotypes snp_map=path_to_map phenotype_file=path_to_phenotypes trait=trait_name_in_phenotype_file trait_label=label_to_use_for_trait

library("qqman")
library("dplyr")
library("sommer")
# library("tidyverse")
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
  'traits',
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

# genotype_file = "introduction_to_gwas/6.steps/rice_imputed.raw"
# snp_map = "introduction_to_gwas/6.steps/rice_imputed.map"
# phenotype_file = "introduction_to_gwas/model_extensions/multi_trait/rice_phenotypes_multi.txt"
# traits = "SL,SW"
# covariates="population"

print(paste("genotype file name:",genotype_file))
print(paste("SNP map:",snp_map))
print(paste("phenotype file name:",phenotype_file))
print(paste("trait:",traits))
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
writeLines("- running GWAS for multiple traits")
# subset phenotypes
# P <- phenotypes %>% dplyr::rename(phenotype = !!as.name(config$trait))
trts = strsplit(traits, split = ",")[[1]]
covs = covariates
P <- dplyr::select(phenotypes, c(id, all_of(trts), all_of(covs)))

pheno <- stackTrait(P, traits = c("SL","SW"))
head(pheno$long)

fmod <- as.formula(
  paste(paste("valueS"),
        paste(c("trait",covs), collapse = "+"),
        sep = " ~ "))

print(fmod)

gblup_multi <- mmes( valueS ~ trait + population, # henderson=TRUE,
                     random=~ vsm(usm(trait), ism(id), Gu=K),
                     rcov=~ vsm(dsm(trait), ism(units)),
                     data=pheno$long)

print("genetic correlations")
print(cov2cor(gblup_multi$theta[[1]]))

###########
### RESULTS
###########
writeLines(" - get marker effects from GBLUP")

## getting the X'(XX')^-1 matrix
Kinv <- solve(K + diag(1e-6, ncol(K), ncol(K)))
XKinv <- t(X)%*%Kinv

## individual genetic effects
g <- gblup_multi$uList$`vsm(usm(trait), ism(id), Gu = K)`
a.from.g <- XKinv %*% g ## marker effects

## first trait
start_1 = gblup_multi$partitions[[1]][1]
end_1 = gblup_multi$partitions[[1]][3]

## Ci is the inverse of the coefficient matrix
var.g <- kronecker(K, gblup_multi$theta[[1]][1]) - gblup_multi$Ci[start_1:end_1,start_1:end_1]

## t statistic
var.a.from.g <- t(X) %*% Kinv %*% (var.g) %*% t(Kinv) %*% X ## variance of marker effects
se.a.from.g <- sqrt(diag(var.a.from.g))  ## standard error of the estimates
t.stat.from.g <- a.from.g[,1]/se.a.from.g # t-statistic

n <- nrow(phenotypes) # to be used for degrees of freedom
k <- 1 # to be used for degrees of freedom (number of levels in fixed effects)
pval_1 <- dt(t.stat.from.g, df=n-k-1) # pvalues

temp <- SNP_INFO
temp$log_pval = -log10(pval_1)
head(temp)

png(paste(dataset,"manhattan_SL.png",sep="_"))
sommer::manhattan(temp, pch=20,cex=1.5, PVCN = "log_pval")
dev.off()

png(paste(dataset,"qqplot_SL.png",sep="_"), width = 600, height = 600)
qqman::qq(pval_1)
dev.off()


## second trait
start_2 = gblup_multi$partitions[[1]][2]
end_2 = gblup_multi$partitions[[1]][4]

## choose the corresponding genetic variance; Ci is the inverse of the coefficient matrix
var.g <- kronecker(K, gblup_multi$theta[[1]][4]) - gblup_multi$Ci[start_2:end_2,start_2:end_2]

## t statistic
var.a.from.g <- t(X) %*% Kinv %*% (var.g) %*% t(Kinv) %*% X ## variance of marker effects
se.a.from.g <- sqrt(diag(var.a.from.g))  ## standard error of the estimates
t.stat.from.g <- a.from.g[,2]/se.a.from.g # t-statistic

n <- nrow(phenotypes) # to be used for degrees of freedom
k <- 1 # to be used for degrees of freedom (number of levels in fixed effects)
pval_2 <- dt(t.stat.from.g, df=n-k-1) # pvalues

temp$log_pval_2 = -log10(pval_2)
head(temp)

png(paste(dataset,"manhattan_SW.png",sep="_"))
sommer::manhattan(temp, pch=20, cex=1.5, PVCN = "log_pval_2")
dev.off()

## qq-plot
png(paste(dataset,"qqplot_SW.png",sep="_"), width = 600, height = 600)
qqman::qq(pval_2)
dev.off()

## rename P to log_p (as it is) and add the column with p-values
names(temp)[4:5] <- c("SL_log_p", "SW_log_p")
fname <- paste(dataset,"multitrait_GWAS.results", sep="_")
fwrite(x = temp, file = fname)


print("#########")
print("## END ##")
print("#########")



