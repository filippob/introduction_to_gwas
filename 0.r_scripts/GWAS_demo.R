
library("rrBLUP")
library("qqman")


##############################################
### I. READ IN GENOTYPE AND PHENOTYPE DATA ###
##############################################

## Genotypes
genotypes <- read.csv("genotypes_demo.csv", header = TRUE, check.names = FALSE)
str(genotypes)
dim(genotypes) # 187 individuals genotypes with 3500 SNP
genotypes[1:5, 1:5] # 0, 1, 2, -9 coding
unique(unlist(genotypes))

## Marker map - chromosome and location for each SNP
map <- read.csv("map_demo.csv", header = TRUE, check.names = FALSE)
str(map)
head(map)
unique(map$chrom)


## Phenotype data
phenotypes <- read.csv("phenotypes_demo.csv", header = TRUE, check.names = FALSE)
str(phenotypes) # Phenotypes for 363 individuals and 4 traits.
head(phenotypes)

## Check if ID order is the same in the genotypes and phenotypes data frames
rownames(genotypes) == phenotypes$id # all ID's match
any(rownames(genotypes) != phenotypes$id) 



####################################################################
### II. RECODE SNP CALLS FOR rrBLUP & FILTER INDIVIDUALS AND SNP ###
####################################################################

genotypes <- as.matrix(genotypes)
genotypes[which(genotypes == -9)] <- NA    # replace -9 by NA, and ...
genotypes <- genotypes - 1                 # convert to -1, 0, 1 SNP coding
genotypes[1:5, 1:5]



### 1. Remove individuals with more than 20% missing marker data (80% of SNP calls are present)
### A high fraction of missing markers might indicate a low genotyping quality.

rm_ind <- as.matrix(rowSums(is.na(genotypes)) / ncol(genotypes)) # fraction of NA per individual
rm_ind <- 1 - rm_ind # fraction of SNP called per individual

length(which(rm_ind < 0.8)) # number of individuals with less than 80% SNP calls (at least 20% NA)
rm_ind <- (which(rm_ind < 0.8))

### Remove individuals from the genotypes AND the phenotypes object.
dim(genotypes)
dim(phenotypes)
if (length(rm_ind) > 0) genotypes <- genotypes[-rm_ind, ]
if (length(rm_ind) > 0) phenotypes <- phenotypes[-rm_ind, ]
dim(genotypes) # Individuals with too many missing markers have been removed
dim(phenotypes) # Individuals with too many missing markers have been removed



### 2. Remove SNP markers with more than 15% missing SNP calls (at least 15% NA per marker)

rm_snp <- as.matrix(colSums(is.na(genotypes)) / nrow(genotypes))
rm_snp <- 1 - rm_snp
length(which(rm_snp < 0.85)) # number of SNP with less than 85% SNP calls.
rm_snp <- (which(rm_snp < 0.85))


### Remove SNP from the genotypes AND the map object.
dim(genotypes)
dim(map)
if (length(rm_snp) > 0) genotypes <- genotypes[ , -rm_snp]
if (length(rm_snp) > 0) map <- map[-rm_snp, ]
dim(genotypes) # SNP with too many missing calls have been removed
dim(map) # SNP with too many missing calls have been removed




### 3. Remove SNP markers falling below an MAF threshold value.
maf <- 0.03
maf_snp <- genotypes + 1  # reconvert to 0, 1, 2 coding to calculate allele frequency

maf_snp[1:5, 1:5]
maf_snp <- as.matrix(colSums(maf_snp, na.rm = TRUE) / (2 * nrow(maf_snp)))

range(maf_snp) # range of allele frequencies
hist(maf_snp, breaks = 200)

maf_A <- which(maf_snp < maf)
maf_B <- which(maf_snp > (1 - maf))
rm_snp_maf <- c(maf_A, maf_B)

### Remove SNP from the genotypes AND the map object.
dim(genotypes)
dim(map)
if (length(rm_snp_maf) > 0) genotypes <- genotypes[ , -rm_snp_maf]
if (length(rm_snp_maf) > 0) map <- map[-rm_snp_maf, ]
dim(genotypes)
dim(map)



### 3.2 ALTERNATIVE TO MAF - minor allele count

mac <- 30 # We want the minor allele to be present with at least 30 copies in the population.
mac_snp <- genotypes + 1
mac_snp <- as.matrix(colSums(mac_snp, na.rm = TRUE)) # count allele copies

range(mac_snp)
hist(mac_snp, breaks = 200)

mac_A <- which(mac_snp < mac)
mac_B <- which(mac_snp > (2 * nrow(genotypes) - mac))
rm_snp_mac <- c(mac_A, mac_B)


### Remove SNP from the genotypes AND the map object.
dim(genotypes)
dim(map)
if (length(rm_snp_mac) > 0) genotypes <- genotypes[ , -rm_snp_mac]
if (length(rm_snp_mac) > 0) map <- map[-rm_snp_mac, ]
dim(genotypes)
dim(map)



################################################################################
### III. IMPUTE MISSING MARKERS AND GENERATE THE GENOMIC RELATIONSHIP MATRIX ###
################################################################################

### When we use rrBLUP to generate the genomic relationship matrix, we
# ... can filter for MAF,
# ... can remove markers with too many missing calls,
# ... can choose between two imputation methods; we choose a simple mean imputation here.

### Note: we included NA's (all individuals) in the calculation of allele frequencies. rrBLUP
### only includes individuals with successful calls in the calculation of allele frequencies 
### (NA's are excluded). This can result in different marker numbers after filtering.


grm <- rrBLUP::A.mat(genotypes,
                     min.MAF = 0,
                     max.missing = 1,
                     impute.method = "mean",
                     return.imputed = TRUE)

g_mat_imputed <- grm$imputed # SNP matrix with imputed missing values
grm <- grm$A # genomic relationship matrix

genotypes[1:5, 1:5]     # pre imputation, and ...
g_mat_imputed[1:5, 1:5] # post imputation.
dim(genotypes)
dim(g_mat_imputed)


### we can view the genomic relationship / population substructure using a heatmap
heatmap(grm)


################################################################################
### IV. RUN A GWAS AND GENERATE A MANHATTAN PLOT TO IDENTIFY POTENTIAL PEAKS ###
################################################################################

### Phenotypes data frame for GWAS in rrBLUP
phe_gwas <- data.frame(id = phenotypes$Name, fruit_shape = phenotypes$fruit_shape)
head(phe_gwas)

### Genotypes data frame for GWAS in rrBLUP
geno_gwas <- data.frame(map, t(g_mat_imputed))
geno_gwas[1:5, 1:6]


### 1. Run GWAS

time_rrBLUP <- Sys.time()                          # measure computation time
gwas_rrblup <- rrBLUP::GWAS(pheno = phe_gwas, 
                            geno = geno_gwas, 
                            K = grm,               # A.mat generated by default if K not provided.
                            fixed = NULL,          # fixed effects?
                            plot = FALSE)
time_rrBLUP <- Sys.time() - time_rrBLUP


## Set threshold for Bonferroni correction
bonf <- -log10(0.05 / nrow(geno_gwas))

gwas_res <- gwas_rrblup
names(gwas_res) <- c("SNP","CHR","BP","P")

## rrBLUP calculates -log10(p) values. These are converted into p-values.
gwas_res$P <- 10^((-gwas_res$P))

## Manhattan plot of -log10(p)-values
qqman::manhattan(gwas_res, 
                 suggestiveline = FALSE, 
                 col = c("skyblue","blue"), 
                 genomewideline = bonf, 
                 logp = TRUE) 

## qq-plot
qqman::qq(gwas_res$P)




### 2. GWAS control scenario: no correction for population structure

### rrBLUP will automatically calculate the GRM if no relationship matrix is provided.
### We can enforce a regression without correction for population structure if we provide
### a diagonal matrix instead of the GRM.

relMat_diag <- diag(nrow(grm))
colnames(relMat_diag) <- rownames(relMat_diag) <- colnames(grm)
str(relMat_diag)


gwas_rrblup_2 <- rrBLUP::GWAS(pheno = phe_gwas, 
                              geno = geno_gwas, 
                              K = relMat_diag,       # Assumption: unrelated individuals.
                              fixed = NULL,          # fixed effects?
                              plot = FALSE)


gwas_res_2 <- gwas_rrblup_2
names(gwas_res_2) <- c("SNP","CHR","BP","P")

## rrBLUP calculates -log10(p) values. These are converted into p-values.
gwas_res_2$P <- 10^((-gwas_res_2$P))

## Manhattan plot of -log10(p)-values
qqman::manhattan(gwas_res_2, 
          suggestiveline = FALSE, 
          col = c("skyblue","blue"), 
          genomewideline = bonf, 
          logp = TRUE) 

## qq-plot
qqman::qq(gwas_res_2$P)


