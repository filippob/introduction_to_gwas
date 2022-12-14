## R script to carry out a GWAS analysis with the package rrBLUP
## kinship matrix used to account for population structure in the data
## input: Plink .raw and .map files + phenotype file
# run as Rscript --vanilla gwas_rrblup.R genotype_file=path_to_genotypes snp_map=path_to_map phenotype_file=path_to_phenotypes trait=trait_name_in_phenotype_file trait_label=label_to_use_for_trait
# run as Rscript --vanilla gwas_rrblup.R genotype_file="rice_selected.raw" all_genotype_file="rice_imputed.raw" snp_map="rice_selected.map" phenotype_file="rice_phenotypes.txt" trait="FLW" trait_label="FLW_trait"

library("afex")
library("qqman")
library("lmtest")
library("ggplot2")
library("gMatrix")
library("ggfortify")
library("tidyverse")
library("data.table")

print("GWAS using GLM for binary traits")

###################################
## read arguments from command line
###################################
allowed_parameters = c(
  'all_genotype_file',
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


print(paste("complete genotype file name:",all_genotype_file))
print(paste("Selected SNP in genotype file name:",genotype_file))
print(paste("SNP map:",snp_map))
print(paste("phenotype file name:",phenotype_file))
print(paste("trait:",trait))
print(paste("trait label:",trait_label))

dataset = basename(genotype_file)

## READING DATA
print("now reading in the data ...")
### genotypes
snp_matrix <- fread(genotype_file, header = TRUE)
snp_matrix_all <- fread(all_genotype_file, header = TRUE)
print(paste(nrow(snp_matrix),"records read from the phenotype file",sep=" "))
SNP_INFO <- fread(snp_map)
names(SNP_INFO) <- c("Chr","SNP","cM","Pos")
SNP_INFO$cM <- NULL

matg <- as.matrix(snp_matrix[,-c(1:6)])
colnames(matg) <- gsub("\\_[A-Z]{1}$","",colnames(matg))
rownames(matg) <- snp_matrix$IID

matg_all <- as.matrix(snp_matrix_all[,-c(1:6)])
colnames(matg_all) <- gsub("\\_[A-Z]{1}$","",colnames(matg_all))
rownames(matg_all) <- snp_matrix$IID

print(paste(nrow(SNP_INFO),"SNPs read from the map file",sep=" "))

if ((ncol(snp_matrix)-6) != nrow(SNP_INFO)) {
  
  stop("!! N. of SNPs in the map file not equal to the number of genotyped SNPs in the genotype file")
  
} else print("N. of SNPs in the map and genotype files is the same: this is correct!!")

################
## subsampling
################
#vec <- sample(1:ncol(matg),1000)
#matg <- matg[,vec]
#SNP_INFO <- SNP_INFO[vec,]
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
K <- gVanRaden.2(matg_all)

vec <- colnames(K) %in% phenotypes$id
K <- K[vec,vec]

#print("producing the heatmap kinship matrix ...")
#pdf(paste(dataset,"_kinship_heatmap",".pdf",sep=""))
#heatmap(K,col=rev(heat.colors(75)))
#dev.off()


#########################
## Principal Components
#########################
print("calculating the Princiapl Components ...")

pc <- prcomp(matg_all)
phenotypes$phenotype <- phenotypes$FLW

#pdf(paste(dataset,"_principal_components",".pdf",sep=""))
#autoplot(pc, data = phenotypes, colour = 'phenotype')
#dev.off()

n <- 3 ## n. of principal components to use for GWAS
phenotypes <- cbind.data.frame(phenotypes,pc$x[,1:n])

###################
## Running the GWAS on permuted data
###################
n_perms=100
print(paste("Running the GWAS on the permutated data set, with",n_perms,"iterations"))

df <- phenotypes[,-c(1,2,3)] ## remove ID column
res = data.frame("SNP"=NULL, "effect"=NULL,"pvalue"=NULL)
pvalue_perm<-length(n_perms)
for(i in 1:ncol(matg)) {
  
  df$snp <- matg[,i]
  snp_name <- colnames(matg)[i]
  
  fit <- glm(phenotypes$phenotype ~ ., data = df, family = "gaussian")
  
  vv <- car::Anova(fit, type = "III")$"Pr(>Chisq)"
  pvalue <- vv[length(vv)]
  snp_effect <- as.numeric(fit$coefficients["snp"])

  for (niter in 1:n_perms){
    permuted.data<-sample(1:dim(phenotypes)[1],dim(phenotypes)[1])
    
    fit <- glm(phenotypes$phenotype[permuted.data] ~ ., data = df, family = "gaussian")
    
    vv <- car::Anova(fit, type = "III")$"Pr(>Chisq)"
    pvalue_perm[niter] <- vv[length(vv)]
  }
  res = rbind.data.frame(res, data.frame("SNP"=snp_name, "effect"=snp_effect,"pvalue"=pvalue,t(pvalue_perm)))
}

###########
### RESULTS
###########

#Select those SNPs which pvalue < HPD5%_fromPT
print("writing out results and figures ...")
res <- merge(SNP_INFO,res,by="SNP")
HPD<-apply(res[,-c(1:5)], 1,quantile,probs=c(0.15))
SNP_pass <- res[(res$pvalue<HPD),]  #This is the data frame of SNPs that passed the Permutation Test


fname <- paste(dataset,trait_label,"GWAS_glm.passedPT.txt", sep="_")
fwrite(x = SNP_pass, file = fname)


## visual
png(paste(dataset,trait_label,"PT_snp.png",sep="_"), width = 600, height = 600)
# Basic density
temp<-(t(SNP_pass[2,-c(1:5)]))
temp<-data.frame("SNP"=temp)
names(temp)<-"SNP"
p <- ggplot(temp,aes(x=SNP)) + 
  geom_density()
p
# Add pvalue and HPD5% lines
p+ geom_vline(aes(xintercept=quantile(temp$SNP,probs=0.05)),
              color="blue", linetype="dashed", size=1) +
  geom_vline(aes(xintercept=SNP_pass$pvalue[2]),
              color="red", linetype="solid", size=1)+
  geom_text(aes(y=0.5,x=quantile(temp$SNP,probs=0.05)), label = "HPD_5%", angle = 90,vjust=-1,col="blue")+
  geom_text(aes(y=0.5,x=SNP_pass$pvalue[2]), label = "p_value", angle = 90,vjust=-1,col="red")

dev.off()


# One box per SNP
foo<-pivot_longer(res,cols=6:dim(res)[2])
foo$SNPpos<-paste(foo$Chr,foo$Pos,sep=":")
SNP_pass$SNPpos<-paste(SNP_pass$Chr,SNP_pass$Pos,sep=":")

png(paste(dataset,trait_label,"PT_allSNP.png",sep="_"), width = 4000, height = 1500)
p1 <- ggplot(foo, aes(x=SNPpos, y=value)) + 
  geom_boxplot() +
  scale_y_reverse()
p1+  geom_point(aes(x=SNPpos,y=pvalue ),shape = 3, colour = "red", fill = "red", size = 1, stroke = 2)+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
dev.off()


print("#########")
print("## END ##")
print("#########")



