## install GenABEL from source
# install.packages("~/Dropbox/cursos/berlin2018/berlin2018/software/GenABEL.data_1.0.0.tar.gz", repos = NULL, type = "source")
# install.packages("~/Dropbox/cursos/berlin2018/berlin2018/software/GenABEL_1.8-0.tar.gz", repos = NULL, type = "source")

library("knitr")
library("dplyr")
library("ggplot2")
library("GenABEL")
library("data.table")
library("reshape2")

### own defined functions
qqPlot <- function(res) {
  
  q <- ggplot(res, aes(-log10( ppoints(length(P) )), -log10(sort(P,decreasing=F))))
  q <- q + geom_point() +  geom_abline(intercept=0,slope=1, col="red")
  q <- q + xlab( expression(Expected~~-log [10] (p)) ) + ylab( expression(Observed~~-log [10] (p)) ) 
  q <- q + ggtitle("")
  
  return(q)
}
#########################


## 1) READING THE DATA IN GENABEL

####################################################################
## !!  NB : YOU FIRST NEED TO TRANSPOSE THE PED/MAP FILES (Plink) !!
####################################################################
pheno = fread("../data/rice_phenotypes.txt")
pheno$sex <- rep(1,nrow(pheno))
fwrite(x = pheno, file = "../data/rice_phenotypes_sex.txt", sep = "\t")

tPed = "../data/rice.tped"
tFam = "../data/rice.tfam"
phenotype_file = "../data/rice_phenotypes_sex.txt"

convert.snp.tped(tped=tPed,
                 tfam=tFam,
                 out="../data/rice.raw",
                 strand="+")


df <- load.gwaa.data(phe=phenotype_file, 
                     gen="../data/rice.raw",
                     force=TRUE
)

###############################################

## 2) EDA with GenABEL

descriptives.marker(df)

mP <- melt(phdata(df))
mP <- mP %>%
  filter(variable != "sex")

kable(head(mP))

qc1 <- check.marker(df, p.level=0, maf = 0.05)
df1 <- df[,qc1$snpok]

K <- ibs(df1,weight = "freq")
K[upper.tri(K)] = t(K)[upper.tri(K)]

heatmap(K,col=rev(heat.colors(75)))

phdata(df1)
gtdata(df1)@chromosome

## GWAS model without accounting for population structure

data2.qt <- qtscore(PH, data = df1, trait="gaussian")
lambda(data2.qt)
plot(data2.qt, df="Pc1df",col = c("red", "slateblue"),pch = 19, cex = .5, main="trait")
descriptives.scan(data2.qt,top=10)

res <- results(data2.qt)
res$SNP <- rownames(res)
res <- res[,c("SNP","Chromosome","Position","Pc1df")]
names(res) <- c("SNP","CHR","BP","P")
res$CHR <- as.integer(as.character(res$CHR))
row.names(res) <- NULL
qqPlot(res)

## Use of the kinship matrix to model population structure
h2a <- polygenic(PH,data=df1,kin=K,trait.type = "gaussian")
df.mm <- mmscore(h2a,df1)
descriptives.scan(df.mm,top=100)
plot(df.mm,col = c("red", "slateblue"),pch = 19, cex = .5, main="phenotype")

lambda(df.mm)$estimate
res <- results(df.mm)
res$SNP <- rownames(res)
res <- res[,c("SNP","Chromosome","Position","Pc1df")]
names(res) <- c("SNP","CHR","BP","P")
res$CHR <- as.integer(as.character(res$CHR))
row.names(res) <- NULL
qqPlot(res)

## Use of principal components to model population structure

df.mm  <- egscore(phdata(df1)$PH,data=df1,kin=K)
plot(df.mm,col = c("red", "slateblue"),pch = 19, cex = .5, main="trait")
descriptives.scan(df.mm,top=10)

lambda(df.mm)$estimate
res <- results(df.mm)
res$SNP <- rownames(res)
res <- res[,c("SNP","Chromosome","Position","Pc1df")]
names(res) <- c("SNP","CHR","BP","P")
res$CHR <- as.integer(as.character(res$CHR))
row.names(res) <- NULL
qqPlot(res)

###################
## binary phenotype
###################

## NB : YOU FIRST NEED TO TRANSPOSE THE PED/MAP FILES (Plink)

pheno = fread("../data/dogs_phenotypes.txt")
pheno$sex <- rep(1,nrow(pheno))
fwrite(x = pheno, file = "../data/dogs_phenotypes_sex.txt", sep = "\t")

# tPed = "../../alternatives_to_GenABEL/data/dogs.tped"
# tFam = "../../alternatives_to_GenABEL/data/dogs.tfam"
tPed = "../data/dogs.tped"
tFam = "../data/dogs.tfam"
phenotype_file = "../data/dogs_phenotypes_sex.txt"

## 
# pp = read.table("pheno_dogs.txt", header = TRUE)
# pp$phenotype = pp$phenotype-1
# write.table(pp, file = "pheno_dogs.txt", col.names = TRUE, quote = FALSE, row.names = FALSE)

convert.snp.tped(tped=tPed,
                 tfam=tFam,
                 out="../data/dogs.raw",
                 strand="+")

df <- load.gwaa.data(phe=phenotype_file, 
                     gen="../data/dogs.raw",
                     force=TRUE
)

descriptives.marker(df)

mP <- melt(phdata(df))
mP <- mP %>%
  filter(variable != "sex")

kable(head(mP))

qc1 <- check.marker(df, p.level=0)
df1 <- df[,qc1$snpok]

K <- ibs(df1,weight = "freq")
K[upper.tri(K)] = t(K)[upper.tri(K)]

heatmap(K,col=rev(heat.colors(75)))

phdata(df1)
gtdata(df1)@chromosome

an0 = qtscore(phenotype,data = df1,trait.type = "binomial")
lambda(an0)

plot(an0)

h2a <- polygenic(phenotype,data=df1,kin=K,trait.type = "binomial",llfun = "polylik")
df.mm <- mmscore(h2a,df1)
descriptives.scan(df.mm,top=100)
plot(df.mm,col = c("red", "slateblue"),pch = 19, cex = .5, main="phenotype")
lambda(df.mm)$estimate

res <- results(df.mm)
res$SNP <- rownames(res)
res <- res[,c("SNP","Chromosome","Position","Pc1df")]
names(res) <- c("SNP","CHR","BP","P")
res$CHR <- as.integer(as.character(res$CHR))
row.names(res) <- NULL
qqPlot(res)

## Use of principal components to model population structure

df.mm  <- egscore(phdata(df1)$phenotype,data=df1,kin=K)
plot(df.mm,col = c("red", "slateblue"),pch = 19, cex = .5, main="trait")
descriptives.scan(df.mm,top=10)

lambda(df.mm)$estimate
res <- results(df.mm)
res$SNP <- rownames(res)
res <- res[,c("SNP","Chromosome","Position","Pc1df")]
names(res) <- c("SNP","CHR","BP","P")
res$CHR <- as.integer(as.character(res$CHR))
row.names(res) <- NULL
qqPlot(res)
