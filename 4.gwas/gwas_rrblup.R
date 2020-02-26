## R script to carry out a GWAS analysis with the package rrBLUP
## kinship matrix used to account for population structure in the data
## input: Plink .raw and .map files + phenotype file
# run as Rscript --vanilla gwas.R genotype_file=path_to_genotypes snp_map=path_to_map phenotype_file=path_to_phenotypes trait=trait_name_in_phenotype_file trait_label=label_to_use_for_trait

library("qqman")
library("dplyr")
library("rrBLUP")
library("gMatrix")
library("data.table")

print("GWAS using the rrBLUP package")

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

genotype_file = "../3.imputation/rice_imputed.raw"
snp_map = "../3.imputation/rice_imputed.map"
phenotype_file = "../data/rice_phenotypes.txt"
trait = "PH"
trait_label = "PH"

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
print(paste(nrow(snp_matrix),"records read from the genotype file",sep=" "))
SNP_INFO <- fread(snp_map)
names(SNP_INFO) <- c("Chr","SNP","cM","Pos")
SNP_INFO$cM <- NULL

X <- as.matrix(snp_matrix[,-c(1:6)])
colnames(X) <- gsub("\\_[A-Z]{1}$","",colnames(X))
rownames(X) <- snp_matrix$IID

SNP_INFO <- bind_cols(SNP_INFO,as.data.frame(t(X)))

print(paste(nrow(SNP_INFO),"SNPs read from the map file",sep=" "))

if ((ncol(snp_matrix)-6) != nrow(SNP_INFO)) {
  
  stop("!! N. of SNPs in the map file not equal to the number of genotyped SNPs in the genotype file")
  
} else print("N. of SNPs in the map and genotype files is the same: this is correct!!")

### phenotypes
phenotypes <- fread(phenotype_file)
print(paste(nrow(phenotypes),"records read from the phenotype file",sep=" "))

phenotypes <- phenotypes[phenotypes$id %in% snp_matrix$IID,]
print(paste(nrow(phenotypes),"records read from the phenotype file after alignment with genotypes",sep=" "))

## kinship matrix
print("Calculating the kinship matrix")
X <- as.matrix(snp_matrix[,-c(1:6)])
colnames(X) <- gsub("\\_[A-Z]{1}$","",colnames(X))
rownames(X) <- snp_matrix$IID

K <- gVanRaden.2(X)

vec <- colnames(K) %in% phenotypes$id
K <- K[vec,vec]

print("writing out the kinship matrix ...")
fname = paste(dataset,".kinship",sep="")
write.table(K, file=fname, quote = FALSE, row.names = FALSE)

print("producing the heatmap kinship matrix ...")
pdf(paste(dataset,"_kinship_heatmap",".pdf",sep=""))
heatmap(K,col=rev(heat.colors(75)))
dev.off()

###################
## Running the GWAS
###################
model1_x <- GWAS(
  pheno = phenotypes,
  geno = SNP_INFO,
  fixed = "population",
  K = K,
  plot = FALSE
)

###########
### RESULTS
###########
print("writing out results and figures ...")
gwasResults <- model1_x[,c("SNP","Chr","Pos","PH")]
names(gwasResults) <- c("SNP","CHR","BP","P")

fname <- paste(dataset,trait_label,"GWAS_rrBLUP.results", sep="_")
fwrite(x = gwasResults, file = fname)

png(paste(dataset,trait_label,"manhattan_rrBLUP.png",sep="_"),)
manhattan(gwasResults, suggestiveline = FALSE, col = c("red","blue"),
          logp = FALSE, width = 800, height = 600, res = 100)
dev.off()

# convert -log(p) back to p-values
p <- 10^((-gwasResults$P))
png(paste(dataset,trait_label,"qqplot_rrBLUP.png",sep="_"), width = 600, height = 600)
qq(p)
dev.off()

print("#########")
print("## END ##")
print("#########")



