## R script to carry out a GWAS analysis
## kinship matrix used to account for population structure in the data
## input: Plink .raw and .map files + phenotype file
# run as Rscript --vanilla gwas.R genotype_file=path_to_genotypes snp_map=path_to_map phenotype_file=path_to_phenotypes trait=trait_name_in_phenotype_file trait_label=label_to_use_for_trait

## libraries
library("qqman")
library("gMatrix")
# library("svglite")
library("data.table")

## include common functions
# source("~/Dropbox/cursos/laval2019/GWAS/software/gwas.r")
# source("~/Dropbox/cursos/laval2019/GWAS/software/emma.r")
source("../software/gwas.r")
source("../software/emma.r")

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

# genotype_file = "../6.pipeline/steps/bracco_imputed.raw"
# snp_map = "../6.pipeline/steps/bracco_imputed.map"
# phenotype_file = "../data/bracco_phenotypes.txt"
# trait = "game"
# trait_label = "game"

print(paste("genotype file name:",genotype_file))
print(paste("SNP map:",snp_map))
print(paste("phenotype file name:",phenotype_file))
print(paste("trait:",trait))
print(paste("trait label:",trait_label))

dataset = basename(genotype_file)

## READING DATA
print("now reading in the data ...")

snpMatrix <- fread(genotype_file)
print(paste(nrow(snpMatrix),"records read from the genotype file",sep=" "))

SNP_INFO <- fread(snp_map)
names(SNP_INFO) <- c("Chr","SNP","cM","Pos")
print(paste(nrow(SNP_INFO),"SNPs read from the map file",sep=" "))

if ((ncol(snpMatrix)-6) != nrow(SNP_INFO)) {
  
  stop("!! N. of SNPs in the map file not equal to the number of genotyped SNPs in the genotype file")

} else print("N. of SNPs in the map and genotype files is the same: this is correct!!")

  
phenotypes <- fread(phenotype_file)
print(paste(nrow(phenotypes),"records read from the phenotype file",sep=" "))

phenotypes <- phenotypes[phenotypes$id %in% snpMatrix$IID,]
print(paste(nrow(phenotypes),"records read from the phenotype file after alignment with genotypes",sep=" "))

## kinship matrix
print("Calculating the kinship matrix")
X <- as.matrix(snpMatrix[,-c(1:6)])
colnames(X) <- gsub("\\_[A-Z]{1}$","",colnames(X))
rownames(X) <- snpMatrix$IID

K <- gVanRaden.2(X)

## reading external kinship matrix
# k <- fread("../6.pipeline/steps/bracco_imputed.rel")
# ids <- fread("../6.pipeline/steps/bracco_imputed.rel.id", header = FALSE)
# k <- as.matrix(k)
# colnames(k) <- ids$V1
# rownames(k) <- ids$V1

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
Y <- as.matrix(phenotypes[,trait, with=FALSE])
rownames(Y) <- phenotypes$id

print("Running GWAS ...")
res <- amm_gwas(Y = Y, X = X, K = K, m = 1, use.SNP_INFO = TRUE)

###########
### RESULTS
###########
print("writing out results and figures ...")
gwasResults <- res[,c("SNP","Chr","Pos","Pval")]
names(gwasResults) <- c("SNP","CHR","BP","P")

fname <- paste(dataset,trait_label,"GWAS.results", sep="_")
fwrite(x = gwasResults, file = fname)

# pdf(paste(dataset,trait_label,"manhattan.pdf",sep="_"), width = 6, height = 4)
# manhattan(gwasResults, suggestiveline = FALSE, col = c("red","blue"))
# dev.off()

# svglite::svglite(paste(dataset,trait_label,"manhattan.svg",sep="_"), width = 8, height = 6, pointsize = 2)
# manhattan(gwasResults, suggestiveline = FALSE, col = c("red","blue"))
# dev.off()

png(paste(dataset,trait_label,"manhattan.png",sep="_"), width = 800, height = 600, res = 100)
manhattan(gwasResults, suggestiveline = FALSE, col = c("red","blue"))
dev.off()

# pdf(paste(dataset,trait_label,"qqplot.pdf",sep="_"), width = 8, height = 8, pointsize = 2)
# qq(gwasResults$P)
# dev.off()

png(paste(dataset,trait_label,"qqplot.png",sep="_"), width = 600, height = 600)
qq(gwasResults$P)
dev.off()


print("#########")
print("## END ##")
print("#########")
