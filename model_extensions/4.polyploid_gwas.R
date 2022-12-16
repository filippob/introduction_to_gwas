
## Package: https://github.com/jendelman/GWASpoly
## Short vignette and manual are available on github
## Reference paper: doi:10.3835/plantgenome2015.08.0073


### short foreword...
## In the polyGWAS package, missing marker data points are imputed with the population mode (most 
## frequent genotype). This might do the job when the proportion of missing markers is low (e.g. 
## SNP array with stringent filtering). With lots of missing information (e.g. GBS), this method
## will not provide the required imputation accuracy for a robust GWAS. Jeff Endelman said he has 
## seen good results with random forest imputation. The KNNI algorithm we used will also work for 
## autopolyploids. Just give it a try, there is not much available in the literature so far and 
## your published results will be interesting for others, too :)

### Library
library(GWASpoly)
library(ggplot2)

### Function to filter for missing markers (not implemented in GWASpoly)
filterGenotypes <- function(grm, misPerMarker = 0.1, misPerInd = 0.1){
  
  grmTmp <- grm[, -(1:3)]
  grmMarkers <- grm[, 1:3]
  
  # remove markers with more than X% missing calls
  rmMarkers <- !(apply(grmTmp, 1, function(x) sum(is.na(x))) / ncol(grmTmp)) > misPerMarker
  grmTmp <- grmTmp[rmMarkers , ]
  grmMarkers <- grmMarkers[rmMarkers , ]
  
  ### remove individuals with more than X% missing markers
  rmInds <- !(sapply(grmTmp, function(x) sum(is.na(x))) / nrow(grmTmp)) > misPerInd
  grmTmp <- grmTmp[ , rmInds]
  
  
  grm <- data.frame(grmMarkers,
                    grmTmp)
  return(grm)
  
}



### GWAS ####################################################################

## Set links to the data sets included in the GWASpoly package
TableS1 <- system.file("extdata", "TableS1.csv", package = "GWASpoly")
TableS2 <- system.file("extdata", "TableS2.csv", package = "GWASpoly")

### Genotype and phenotype data files have to follow the structure as 
### illustrated below to work with GWASpoly

## Check the data sets
genoData <- read.csv(TableS1, check.names = FALSE)
phenoData <- read.csv(TableS2, check.names = FALSE)

# Three formats can be used for marker coding (see vignette)
genoData[1:10, 1:10]  # markers = rows, individuals in columns
str(genoData)
dim(genoData)

### Filter for missing markers
genoFiltered <- filterGenotypes(genoData, 0.1, 0.1)
dim(genoFiltered)


### The column names in the original file contain "-" and "( )".
### R is not happy with that and replaces them by "." when writing files.
### As a result, names between genotypes and phenotypes do not match anymore.
### Hence, we need to format the names in the phenoype file accordingly,
### store it, and read it in again.

write.table(genoFiltered, file = "filteredGenotypes.csv",
            quote = FALSE, row.names = FALSE, 
            sep = ",")

phenoData$Name <- gsub("-", "\\.", phenoData$Name)
phenoData$Name <- gsub("[(]", "\\.", phenoData$Name)
phenoData$Name <- gsub("[)]", "\\.", phenoData$Name)

write.table(phenoData, file = "phenoNew.csv",
            quote = FALSE, row.names = FALSE, 
            sep = ",")

TableS1new <- "filteredGenotypes.csv"
genoData2 <- read.csv(TableS1new)

TableS2new <- "phenoNew.csv"
phenoData2 <- read.csv(TableS1new)

phenoData2[1:4, ] # individuals in rows, traits in columns
str(phenoData2)
summary(phenoData2)

## read in data for GWASpoly
## note structure of the phenotype file required for GWASpoly
## 1st column: IDs (Names)
## column 2 - (n.traits + 1): traits (n.traits = 13)
## columns following traits are interpreted as fixed effects,
## e.g. population structure (Grp1 - Grp4)

data <- read.GWASpoly(ploidy = 4, 
                      #pheno.file = TableS2,
                      pheno.file = TableS2new,
                      #geno.file = TableS1,
                      geno.file = TableS1new,
                      format = "ACGT",
                      n.traits = 13,
                      delim=",")

## calculate genomic relationship matrix

data <- set.K(data) # stored already in object "data" 

## Extract genomic relationship matrix. 
## A PCA can be applied on this GRM to analyse population structure
## just like  we do it in diploids (scree plots)
GRM <- data@K
GRM[1:5, 1:5]

## Set.params ...

## Change default MAF and maximum genotype frequency
params1 <- set.params(MAF = 0.02, geno.freq = 0.9) 

## Define fixed effects (Group effects) 
## and change default MAF and maximum genotype frequency
params2 <- set.params(MAF = 0.02, geno.freq = 0.9,
                      fixed=c("Grp1","Grp2","Grp3","Grp4"),
                      fixed.type=rep("numeric",4))



#K model (default when no params are passed to the function)
data1 <- GWASpoly(data,models=c("additive","1-dom"),
                  traits=c("tuber_shape","tuber_eye_depth"),
                  params = params1)

#P+K model
data2 <- GWASpoly(data,models=c("additive","1-dom"),
                  traits=c("tuber_shape","tuber_eye_depth"),
                  params=params2)


#K model
qq.plot(data1) + ggtitle(label="K model")

#P+K model
qq.plot(data2) + ggtitle(label="P+K model")

## Manhattan plots
manhattan.plot(data1)
manhattan.plot(data2)


## Extracting significant loci
# data1 contains scores and effects for all the tested markers
# - scores -log10(p) results
# - effects estimated marker effects
str(data1) 

## Classic Bonferroni Correction
data1 <- set.threshold(data1,method="Bonferroni",level=0.05)

## The FDR method is based on version 1.30.0 of the qvalue package.
data1 <- set.threshold(data1,method="FDR",level=0.10)

## The default method, "M.eff", is a Bonferroni-type correction 
## but using an effective number of markers that accounts for LD 
## between markers (Moskvina and Schmidt, 2008).
data1 <- set.threshold(data1,method="M.eff",level=0.05)


data1 <- set.threshold(data1,method="Bonferroni",level=0.05).
data1 <- set.threshold(data1,method="FDR",level=0.10)
data1 <- set.threshold(data1,method="M.eff",level=0.05)
get.QTL(data1)

data2 <- set.threshold(data2,method="FDR",level=0.10)
get.QTL(data2)
