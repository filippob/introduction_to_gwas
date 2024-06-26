# # A first GWAS demonstration

library("qqman")
library("rrBLUP")

# Let's set a basefolder to be able to read in data from external files in a platform-independent way:

basefolder = "/home/filippo/Dropbox/cursos/gwas_2024/introduction_to_gwas"

# ---
# ## SECTION I: READ IN GENOTYPE AND PHENOTYPE DATA 
#
# ### 1 Genotypes
#
# Let's read an example genotype data file:

file.path(basefolder, "example_data/genotypes_demo.csv")

## Genotypes
genotypes <- read.csv(file.path(basefolder, "example_data/genotypes_demo.csv"), header = TRUE, check.names = FALSE)
str(genotypes) ## str() displays the internal structure of an R object

dim(genotypes) # 187 individuals genotypes with 3500 SNP

genotypes[1:5, 1:5] # 0, 1, 2, -9 coding
unique(unlist(genotypes))

# Together with genotype data (SNP genotypes for each sample), we usually need also a file with information of position (chromosome, bps) for each SNP (**map file**)

## Marker map - chromosome and location for each SNP
map <- read.csv(file.path(basefolder, "example_data/map_demo.csv"), header = TRUE, check.names = FALSE)
str(map)


head(map)
unique(map$chrom)

# ### 2 Phenotypes

## Phenotype data
phenotypes <- read.csv(file.path(basefolder, "example_data/phenotypes_demo.csv"), header = TRUE, check.names = FALSE)
str(phenotypes) # Phenotypes for 363 individuals and 4 traits.
head(phenotypes)

## Check if ID order is the same in the genotypes and phenotypes data frames
rownames(genotypes) == phenotypes$Name # all ID's match
sum(rownames(genotypes) != phenotypes$Name) ## count the n. of mismatches
any(rownames(genotypes) != phenotypes$Names) 

# ---
# ## SECTION II: RECODE SNP CALLS FOR rrBLUP & FILTER INDIVIDUALS AND SNP

genotypes <- as.matrix(genotypes)
genotypes[which(genotypes == -9)] <- NA    # replace -9 by NA, and ...
genotypes <- genotypes - 1                 # convert to -1, 0, 1 SNP coding
genotypes[1:5, 1:5]

# ### 1. Remove individuals with more than 20% missing marker data (80% of SNP calls are present)
#
# A high fraction of missing markers might indicate a low genotyping quality.

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

# ### 2. Remove SNP markers with more than 15% missing SNP calls (at least 15% NA per marker)

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

# ### 3. Remove SNP markers falling below an MAF threshold value.

maf <- 0.03
maf_snp <- genotypes + 1  # reconvert to 0, 1, 2 coding to calculate allele frequency

maf_snp[1:5, 1:5]

maf_snp <- as.matrix(colSums(maf_snp, na.rm = TRUE) / (2 * nrow(maf_snp)))
maf_snp

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

# ### 3.2 ALTERNATIVE TO MAF - minor allele count
#
# Before we used a $3\%$ threshold for MAF: with 178 samples, this implies a minimum of 11 copies of the minor allele in the sampled population. 
#
# We can be more specific and set the minimum n. of alleles we want to have for our GWAS analysis:

mac <- 30 # We want the minor allele to be present with at least 30 copies in the population.
mac_snp <- genotypes + 1
mac_snp <- as.matrix(colSums(mac_snp, na.rm = TRUE)) # count allele copies

range(mac_snp) ## n_samples x 2 is the maximum value possible (e.g. 178 x 2 = 356)
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

# ---
# ## SECTION III: IMPUTE MISSING MARKERS AND GENERATE THE GENOMIC RELATIONSHIP MATRIX

# When we use **rrBLUP to generate the genomic relationship matrix**, we can:
#
# - filter for MAF,
# - remove markers with too many missing calls,
# - choose between two imputation methods; we choose a simple mean imputation here.

# Note: we included NA's (all individuals) in the calculation of allele frequencies. rrBLUP
# only includes individuals with successful calls in the calculation of allele frequencies 
# (NA's are excluded). This can result in different marker numbers after filtering.


grm <- rrBLUP::A.mat(genotypes,
                     min.MAF = 0.05,
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


# ---
#
# ## SECTION IV:  RUN A GWAS AND GENERATE A MANHATTAN PLOT TO IDENTIFY POTENTIAL PEAKS
#
# We pick one phenotype from our dataset and use it to run the GWAS:
#

head(phenotypes)

### Phenotypes data frame for GWAS in rrBLUP
phe_gwas <- data.frame(id = phenotypes$Name, fruit_shape = phenotypes$fruit_shape)
head(phe_gwas)

# ### Genotypes data frame for GWAS in rrBLUP

### select SNPs that were not filtered out
vec <- map$marker %in% colnames(g_mat_imputed)
map_filtered = map[vec,]

geno_gwas <- data.frame(map_filtered, t(g_mat_imputed))
geno_gwas[1:5, 1:6]


# ### 1. Run GWAS

time_rrBLUP <- Sys.time()                          # measure computation time
gwas_rrblup <- rrBLUP::GWAS(pheno = phe_gwas, 
                            geno = geno_gwas, 
                            K = grm,               # A.mat generated by default if K not provided.
                            fixed = NULL,          # fixed effects?
                            plot = FALSE)
time_rrBLUP <- Sys.time() - time_rrBLUP


time_rrBLUP

## Set threshold for Bonferroni correction
bonf <- -log10(0.05 / nrow(geno_gwas))
print(bonf)

gwas_res <- gwas_rrblup
names(gwas_res) <- c("SNP","CHR","BP","P")
head(gwas_res)

## rrBLUP calculates -log10(p) values. These are converted into p-values.
gwas_res$P <- 10^((-gwas_res$P))
head(gwas_res)

## Manhattan plot of -log10(p)-values
qqman::manhattan(gwas_res, 
                 suggestiveline = FALSE, 
                 col = c("skyblue","blue"), 
                 genomewideline = bonf, 
                 logp = TRUE) 

## qq-plot
qqman::qq(gwas_res$P)

# ### 2. GWAS control scenario: no correction for population structure

# !!Mind: rrBLUP will automatically calculate the GRM if no relationship matrix is provided.
# We can enforce a regression without correction for population structure if we provide
# a diagonal matrix instead of the GRM.

relMat_diag <- diag(nrow(grm))
colnames(relMat_diag) <- rownames(relMat_diag) <- colnames(grm)
str(relMat_diag)


heatmap(relMat_diag)

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

# ## SECTION V: DO IT YOURSELF
#
# - `map_fruit_sim.csv`
# - `genotypes_fruit_sim.csv`
# - `phenotypes_fruit_sim.csv`
#
# #### Read the data

# +
library("data.table")

genotypes <- read.csv("../example_data/genotypes_fruit_sim.csv")
map <- fread("../example_data/map_fruit_sim.csv")
phenotypes <- fread("../example_data/phenotypes_fruit_sim.csv")
# -

# #### Explore and describe
#
# - how many?
# - what?
# - have a look?

print(paste("N. of genotyped samples:", nrow(genotypes)))
print(paste("N. of phenotyped samples:", nrow(phenotypes)))
print(paste("N. of SNPs:", nrow(map)))

head(genotypes)

summary(phenotypes)

# #### Recode and filter

genotypes <- as.matrix(genotypes)
genotypes[which(genotypes == -9)] <- NA    # replace -9 by NA, and ...
genotypes <- genotypes - 1                 # convert to -1, 0, 1 SNP coding
genotypes[1:5, 1:5]

# Let's first check that our genotyped and phenotyped samples are in the **same order**:

sum(phenotypes$id == rownames(genotypes)) == nrow(phenotypes)

# Now, let's say that we pick the trait `Yield` for our GWAS and that we want to remove the sample with the missing phenotype value. Mind you: we need to remove that sample from the phenotype and from the genotype file

nid = which(is.na(phenotypes$Yield))
phenotypes = phenotypes[-nid,]
genotypes = genotypes[-nid,]
dim(phenotypes)
dim(genotypes)

summary(phenotypes)

# Now, we proceed with filtering for **missing rate** and **MAF**:

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

maf <- 0.05
maf_snp <- genotypes + 1
maf_snp <- as.matrix(colSums(maf_snp, na.rm = TRUE) / (2 * nrow(maf_snp)))
summary(maf_snp)

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

# #### Impute missing genotypes and calculate the kinship matrix

# +
grm <- rrBLUP::A.mat(genotypes,
                     min.MAF = 0.05,
                     max.missing = 1,
                     impute.method = "mean",
                     return.imputed = TRUE)

g_mat_imputed <- grm$imputed # SNP matrix with imputed missing values
grm <- grm$A # genomic relationship matrix
# -

heatmap(grm)

# #### Run GWAS
#
# First, we prepare the phenotype and genotype data:

### Phenotypes data frame for GWAS in rrBLUP
phe_gwas <- data.frame(id = phenotypes$id, trait = phenotypes$Yield)
head(phe_gwas)

# +
### select SNPs that were not filtered out
vec <- map$marker %in% colnames(g_mat_imputed)
map_filtered = map[vec,]

geno_gwas <- data.frame(map_filtered, t(g_mat_imputed))
geno_gwas[1:5, 1:6]
# -

# Finally, we run the GWAS model:

gwas_rrblup <- rrBLUP::GWAS(pheno = phe_gwas, 
                            geno = geno_gwas, 
                            K = grm,               # A.mat generated by default if K not provided.
                            fixed = NULL,          # fixed effects?
                            plot = FALSE)

# #### Evaluate results

# +
## Set threshold for Bonferroni correction
bonf <- -log10(0.05 / nrow(geno_gwas))
print(bonf)

gwas_res <- gwas_rrblup
names(gwas_res) <- c("SNP","CHR","BP","P")
head(gwas_res)
# -

summary(gwas_res)

# `rrBLUP::GWAS()` returns -log (p-values), so we need to convert them back to p-values:

## rrBLUP calculates -log10(p) values. These are converted into p-values.
gwas_res$P <- 10^((-gwas_res$P))
summary(gwas_res)

## Manhattan plot of -log10(p)-values
qqman::manhattan(gwas_res, 
          suggestiveline = FALSE, 
          col = c("skyblue","blue"), 
          genomewideline = bonf, 
          logp = TRUE) 

## qq-plot
qqman::qq(gwas_res$P)
