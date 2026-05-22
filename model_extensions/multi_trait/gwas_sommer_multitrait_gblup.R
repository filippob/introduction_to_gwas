## R script to carry out a GWAS analysis with the package rrBLUP
## kinship matrix used to account for population structure in the data
## input: Plink .raw and .map files + phenotype file
# run as Rscript --vanilla gwas_sommer.R genotype_file=path_to_genotypes snp_map=path_to_map phenotype_file=path_to_phenotypes trait=trait_name_in_phenotype_file trait_label=label_to_use_for_trait

library("tidyr")
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
K <-A.mat(X-1)

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
writeLines("- running GWAS for multiple traits: GBLUP model")
# subset phenotypes
# P <- phenotypes %>% dplyr::rename(phenotype = !!as.name(config$trait))
trts = strsplit(traits, split = ",")[[1]]
covs = covariates
P <- dplyr::select(phenotypes, c(id, all_of(trts), all_of(covs)))

## center and scale
P <- mutate(P, across(all_of(trts), ~ scale(.) %>% as.vector()))

# pheno <- stackTrait(P, traits = c("SL","SW"))
# pheno_long <- P %>%
#   pivot_longer(
#     cols = c("SL", "SW"),      # the trait columns
#     names_to = "trait",        # new column for trait names
#     values_to = "value"        # new column for trait values
#   )

# Optional: keep population as a factor
# pheno_long$population <- as.factor(pheno_long$population)

# View first rows
# head(pheno_long)

fit <- mmer(cbind(SL, SW) ~ population,
            random = ~ vsr(id, Gu = K, Gtc = unsm(2)),
            rcov   = ~ vsr(units, Gtc = unsm(2)),
            data = P)

print(summary(fit))

print("genetic correlations")
## genetic vars
genetic_var <- diag(fit$sigma$`u:id`)
# Residual variances
residual_var <- diag(fit$sigma$`u:units`)
## genetic covariance
cov_SL_SW = fit$sigma$`u:id`["SL","SW"]
## residual covariance
cov_res <- fit$sigma$`u:units`["SL","SW"]

cor_SL_SW <- cov_SL_SW / sqrt(genetic_var["SL"] * genetic_var["SW"])
res_cor <- cov_res / sqrt(residual_var["SL"] * residual_var["SW"])
print(cor_SL_SW)

###########
### RESULTS
###########
writeLines(" - get marker effects from GBLUP")

## getting the X'(XX')^-1 matrix
Kinv <- solve(K + diag(rnorm(ncol(K))/1e+3, ncol(K), ncol(K)))
Xc = scale(X, center = TRUE, scale = FALSE) 
XKinv <- t(Xc)%*%Kinv

## individual genetic effects
g_sl <- fit$U$`u:id`$SL

## 1) get SNP effects --> β_SNP = t(X) * K^-1 * g
## X(n,m); K(n,n); g(n,1) --> β_SNP(m,1) 
beta_hat_sl <- XKinv %*% g_sl ## marker effects

## 2) get the standard errors: Var(β_SNP)=X(K^−1)Var(g)(K−1)t(X)
## X(n,m); K(n,n); Var(g)(n,n) --> Var(β_SNP)(m,m)
varg_sl = fit$VarU$`u:id`$SL
cov_beta_sl <- t(X) %*% Kinv %*% varg_sl %*% t(Kinv) %*% X
var_beta_sl = diag(cov_beta_sl)

# Standard errors
se_beta <- sqrt(var_beta_sl)

## 3) t-statistc = β_SNP  / SE(β_SNP)
## all (m,1)
tstat = beta_hat_sl/se_beta

## 4) p-values (two-sided)
p_values <- 2 * (1 - pnorm(abs(tstat)))

# to_save = list("fit" = fit, "K" = K, "X" = X)
# save(to_save, file = "multi-trait-fit.RData")

temp <- SNP_INFO
temp$log_pval = -log10(p_values)
head(temp)
# 
png(paste(dataset,"manhattan_SL.png",sep="_"))
manhattan(temp, pch=20,cex=1.5, PVCN = "log_pval")
dev.off()
# 
png(paste(dataset,"qqplot_SL.png",sep="_"), width = 600, height = 600)
qqman::qq(p_values)
dev.off()

#################
# ## second trait
#################
## individual genetic effects
g_sw <- fit$U$`u:id`$SW

## 1) get SNP effects --> β_SNP = t(X) * K^-1 * g
## X(n,m); K(n,n); g(n,1) --> β_SNP(m,1) 
beta_hat_sw <- XKinv %*% g_sw ## marker effects

## 2) get the standard errors: Var(β_SNP)=X(K^−1)Var(g)(K−1)t(X)
## X(n,m); K(n,n); Var(g)(n,n) --> Var(β_SNP)(m,m)
varg_sw = fit$VarU$`u:id`$SW
cov_beta_sw <- t(X) %*% Kinv %*% varg_sw %*% t(Kinv) %*% X
var_beta_sw = diag(cov_beta_sw)

# Standard errors
se_beta <- sqrt(var_beta_sw)

## 3) t-statistc = β_SNP  / SE(β_SNP)
## all (m,1)
tstat = beta_hat_sw/se_beta

## 4) p-values (two-sided)
p_values_sw <- 2 * (1 - pnorm(abs(tstat)))

temp <- SNP_INFO
temp$log_pval = -log10(p_values_sw)
head(temp)
# 
png(paste(dataset,"manhattan_SW.png",sep="_"))
manhattan(temp, pch=20,cex=1.5, PVCN = "log_pval")
dev.off()
# 
png(paste(dataset,"qqplot_SW.png",sep="_"), width = 600, height = 600)
qqman::qq(p_values)
dev.off()


print("#########")
print("## END ##")
print("#########")



