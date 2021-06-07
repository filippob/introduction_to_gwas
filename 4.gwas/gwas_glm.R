## R script to carry out a GWAS analysis with the package rrBLUP
## kinship matrix used to account for population structure in the data
## input: Plink .raw and .map files + phenotype file
# run as Rscript --vanilla gwas_rrblup.R genotype_file=path_to_genotypes snp_map=path_to_map phenotype_file=path_to_phenotypes trait=trait_name_in_phenotype_file trait_label=label_to_use_for_trait

library("afex")
library("qqman")
library("lmtest")
library("gMatrix")
library("ggfortify")
library("tidyverse")
library("data.table")

print("GWAS using GLM for binary traits")

###################################
## read arguments from command line
###################################
allowed_parameters = c(
  'genotype_file',
  'snp_map',
  'phenotype_file',
  'trait',
  'trait_label'
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

# genotype_file = "introduction_to_gwas/6.steps/dogs_imputed.raw"
# snp_map = "introduction_to_gwas/6.steps/dogs_imputed.map"
# phenotype_file = "introduction_to_gwas/6.steps/data/dogs_phenotypes.txt"
# trait = "phenotype"
# trait_label = "cleft_lip "

print(paste("genotype file name:",genotype_file))
print(paste("SNP map:",snp_map))
print(paste("phenotype file name:",phenotype_file))
print(paste("trait:",trait))
print(paste("trait label:",trait_label))

dataset = basename(genotype_file)

## READING DATA
print("now reading in the data ...")
### genotypes
snp_matrix <- fread(genotype_file, header = TRUE)
print(paste(nrow(snp_matrix),"records read from the phenotype file",sep=" "))
SNP_INFO <- fread(snp_map)
names(SNP_INFO) <- c("Chr","SNP","cM","Pos")
SNP_INFO$cM <- NULL

matg <- as.matrix(snp_matrix[,-c(1:6)])
colnames(matg) <- gsub("\\_[A-Z]{1}$","",colnames(matg))
rownames(matg) <- snp_matrix$IID

print(paste(nrow(SNP_INFO),"SNPs read from the map file",sep=" "))

if ((ncol(snp_matrix)-6) != nrow(SNP_INFO)) {
  
  stop("!! N. of SNPs in the map file not equal to the number of genotyped SNPs in the genotype file")
  
} else print("N. of SNPs in the map and genotype files is the same: this is correct!!")

################
## subsampling
################
vec <- sample(1:ncol(matg),1000)
matg <- matg[,vec]
SNP_INFO <- SNP_INFO[vec,]
####

### phenotypes
print("now reading in the binary phenotype ...")
phenotypes <- fread(phenotype_file)
phenotypes <- phenotypes[,c(1,3)]
head(phenotypes)
print(paste(nrow(phenotypes),"records read from the phenotype file",sep=" "))

phenotypes <- phenotypes[phenotypes$id %in% snp_matrix$IID,]
print(paste(nrow(phenotypes),"records read from the phenotype file after alignment with genotypes",sep=" "))

## kinship matrix
print("Calculating the kinship matrix")
K <- gVanRaden.2(matg)

vec <- colnames(K) %in% phenotypes$id
K <- K[vec,vec]

print("producing the heatmap kinship matrix ...")
pdf(paste(dataset,"_kinship_heatmap",".pdf",sep=""))
heatmap(K,col=rev(heat.colors(75)))
dev.off()


#########################
## Principal Components
#########################
pc <- prcomp(matg)
phenotypes$phenotype <- factor(phenotypes$phenotype)
phenotypes <- phenotypes %>% dplyr::rename(phenotype = !!as.name(trait))

pdf(paste(dataset,"_principal_components",".pdf",sep=""))
autoplot(pc, data = phenotypes, colour = 'phenotype')
dev.off()

n <- 3 ## n. of principal components to use for GWAS
phenotypes <- cbind.data.frame(phenotypes,pc$x[,1:n])

###################
## Running the GWAS
###################

df <- phenotypes[,-1] ## remove ID column
res = data.frame("SNP"=NULL, "effect"=NULL,"pvalue"=NULL)

for(i in 1:ncol(matg)) {
  
  df$snp <- matg[,i]
  snp_name <- colnames(matg)[i]
  
  fit <- glm(phenotype ~ ., data = df, family = binomial(link = "logit"))
  
  vv <- car::Anova(fit, type = "III")$"Pr(>Chisq)"
  pvalue <- vv[length(vv)]
  snp_effect <- as.numeric(fit$coefficients["snp"])

  res = rbind.data.frame(res, data.frame("SNP"=snp_name, "effect"=snp_effect,"pvalue"=pvalue))
}

###########
### RESULTS
###########
print("writing out results and figures ...")
res <- merge(res,SNP_INFO,by="SNP")
res <- select(res,c(SNP,Chr,Pos,effect,pvalue))

fname <- paste(dataset,trait_label,"GWAS_glm.results", sep="_")
fwrite(x = res, file = fname)

res$effect <- NULL
names(res) <- c("SNP","CHR","BP","P")

png(paste(dataset,trait_label,"manhattan_glm.png",sep="_"))
qqman::manhattan(res, suggestiveline = TRUE, col = c("red","blue"), 
          genomewideline = FALSE, logp = TRUE, width = 800, height = 600, res = 100)
dev.off()

## qq-plot
png(paste(dataset,trait_label,"qqplot_glm.png",sep="_"), width = 600, height = 600)
qq(res$P)
dev.off()

print("#########")
print("## END ##")
print("#########")



