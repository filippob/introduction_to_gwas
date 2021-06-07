## R script to carry out a GWAS analysis with the package rrBLUP
## kinship matrix used to account for population structure in the data
## input: Plink .raw and .map files + phenotype file
# run as Rscript --vanilla gwas_genabel.R genotype_file=path_to_genotypes fam_file=path_to_fam phenotype_file=path_to_phenotypes trait=trait_name_in_phenotype_file trait_label=label_to_use_for_trait

library("afex")
library("qqman")
library("GenABEL")
library("gMatrix")
library("tidyverse")
library("data.table")

print("GWAS using GenABEL")

###################################
## read arguments from command line
###################################
allowed_parameters = c(
  'genotype_file',
  'fam_file',
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

# genotype_file = "introduction_to_gwas/6.steps/dogs_imputed.tped"
# fam_file = "introduction_to_gwas/6.steps/dogs_imputed.tfam"
# phenotype_file = "introduction_to_gwas/6.steps/data/dogs_phenotypes.txt"
# trait = "phenotype"
# trait_label = "cleft_lip"

print(paste("genotype file name:",genotype_file))
print(paste("SNP map:",fam_file))
print(paste("phenotype file name:",phenotype_file))
print(paste("trait:",trait))
print(paste("trait label:",trait_label))

dataset = basename(genotype_file)

## READING DATA
print("now reading in the data ...")

## 1) READING THE DATA IN GENABEL

####################################################################
## !!  NB : YOU FIRST NEED TO TRANSPOSE THE PED/MAP FILES (Plink) !!
####################################################################
pheno = fread(phenotype_file)
pheno <- pheno %>% dplyr::rename(phenotype = !!as.name(trait))
pheno$sex <- rep(1,nrow(pheno))
fname <- paste(gsub("\\..*$","",dataset),"_sex.txt",sep="")
fwrite(x = pheno, file = fname, sep = "\t")

convert.snp.tped(tped=genotype_file,
                 tfam=fam_file,
                 out="temp.raw",
                 strand="+")


df <- load.gwaa.data(phe=fname, 
                     gen="temp.raw",
                     force=TRUE
)

## kinship matrix
K <- ibs(df, weight = "freq")
K[upper.tri(K)] = t(K)[upper.tri(K)]

print("producing the heatmap kinship matrix ...")
pdf(paste(dataset,"_kinship_heatmap",".pdf",sep=""))
heatmap(K,col=rev(heat.colors(75)))
dev.off()

###################
## Running the GWAS
###################
## Use of the kinship matrix to model population structure
mod_genabel <- polygenic(phenotype, data=df, kin=K, trait.type = "binomial")
df.mm <- mmscore(mod_genabel, df)

###########
### RESULTS
###########
print("writing out results and figures ...")
png(paste(dataset,trait_label,"manhattan_genabel.png",sep="_"))
plot(df.mm,col = c("red", "slateblue"),pch = 19, cex = .5, main="phenotype")
dev.off()

# print(paste("lambda", lambda(df.mm)$estimate))

res <- results(df.mm)
res$SNP <- rownames(res)
res <- res[,c("SNP","Chromosome","Position","Pc1df")]
names(res) <- c("SNP","CHR","BP","P")
res$CHR <- as.integer(as.character(res$CHR))
row.names(res) <- NULL

fname <- paste(dataset,trait_label,"GWAS_genabel.results", sep="_")
fwrite(x = res, file = fname)

## qq-plot
png(paste(dataset,trait_label,"qqplot_genabel.png",sep="_"), width = 600, height = 600)
qqman::qq(res$P)
dev.off()


print("#########")
print("## END ##")
print("#########")



