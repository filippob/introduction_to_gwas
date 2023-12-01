#GWAS - RStudio
library("qqman")
library("dplyr")
library("rrBLUP")
#library("gMatrix")
library("data.table")

print("GWAS using the rrBLUP package")

genotype_file = "pigs_imputed.raw"
snp_map = "pigs_imputed.map"
phenotype_file = "pigs_phenotypes.txt"
trait = "trait"
trait_label = "trait"

# gwidethre = "bonferroni"
gwidethre = ""

print(paste("genotype file name:",genotype_file))
print(paste("SNP map:",snp_map))
print(paste("phenotype file name:",phenotype_file))
print(paste("trait:",trait))
print(paste("trait label:",trait_label))

print(paste("method for genome-wide significance line", gwidethre))

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
phenotypes <- phenotypes[,c(2,3)]
names(phenotypes) <- c("id","trait")

phenotypes$id=gsub("_","",phenotypes$id)

print(paste(nrow(phenotypes),"records read from the phenotype file",sep=" "))

phenotypes <- phenotypes[phenotypes$id %in% snp_matrix$IID,]
print(paste(nrow(phenotypes),"records read from the phenotype file after alignment with genotypes",sep=" "))

## kinship matrix
print("Calculating the kinship matrix")
X <- as.matrix(snp_matrix[,-c(1:6)])
colnames(X) <- gsub("\\_[A-Z]{1}$","",colnames(X))
rownames(X) <- snp_matrix$IID

# K <- gVanRaden.2(X)
K <- rrBLUP::A.mat(X)

vec <- colnames(K) %in% phenotypes$id
K <- K[vec,vec]

SNP_INFO <- as.data.frame(SNP_INFO)
SNP_INFO <- SNP_INFO[,c(TRUE,TRUE,TRUE,vec)]

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
## Set threshold for Bonferroni correction
sign_thre <- ifelse(gwidethre == "bonferroni", -log10(0.05 / nrow(SNP_INFO)), -log10(1e-2))

model1_x <- GWAS(
  pheno = phenotypes,
  geno = SNP_INFO,
  # fixed = "population",
  K = K,
  plot = FALSE
)

###########
### RESULTS
###########
print("writing out results and figures ...")
names(model1_x)[length(model1_x)] <- trait
gwasResults <- model1_x[,c("SNP","Chr","Pos",trait)]
names(gwasResults) <- c("SNP","CHR","BP","P")

png(paste(dataset,trait_label,"manhattan_rrBLUP.png",sep="_"))
qqman::manhattan(gwasResults, suggestiveline = FALSE, col = c("red","skyblue"), 
          genomewideline = sign_thre, logp = FALSE)
dev.off()

# convert -log(p) back to p-values
p <- 10^((-gwasResults$P))

## rename P to log_p (as it is) and add the column with p-values
names(gwasResults)[4] <- "log_p"
gwasResults$P <- p

fname <- paste(dataset,trait_label,"GWAS_rrBLUP.results", sep="_")
fwrite(x = gwasResults, file = fname)

## qq-plot
png(paste(dataset,trait_label,"qqplot_rrBLUP.png",sep="_"), width = 600, height = 600)
qqman::qq(p)
dev.off()


