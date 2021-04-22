## R script to carry out a GWAS analysis with the package statgenGWAS
## kinship matrix used to account for population structure in the data
## input: Plink .raw and .map files + phenotype file
# run as Rscript --vanilla gwas_statgengwas.R genotype_file=path_to_genotypes snp_map=path_to_map phenotype_file=path_to_phenotypes trait=trait_name_in_phenotype_file trait_label=label_to_use_for_trait

memory.limit(size = 8000)

library("R.utils")
library("tidyverse")
library("data.table")
library("statgenGWAS")

print("GWAS using the statgenGWAS package")

# output_path="../../gwas"

###################################
## read arguments from command line
###################################
allowed_parameters = c(
  'genotype_file',
  'snp_map',
  'phenotype_file',
  'trait',
  'trait_label',
  'systematic_effects'
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

# genotype_file = "introduction_to_gwas/3.imputation/dogs_imputed.raw"
# snp_map = "introduction_to_gwas/3.imputation/dogs_imputed.map"
# phenotype_file = "introduction_to_gwas/data/dogs_phenotypes.txt"
# trait = "phenotype"
# trait_label = "cleft_lip"
# systematic_effects = "age,gender,n_comorbidities"

print(paste("genotype file name:",genotype_file))
print(paste("SNP map:",snp_map))
print(paste("phenotype file name:",phenotype_file))
print(paste("trait:",trait))
print(paste("trait label:",trait_label))
print(paste("systematic effects:",systematic_effects))

if(systematic_effects != "") {
  
  systematic_effects_vec = strsplit(systematic_effects, split = ",")[[1]]
}

dataset = basename(genotype_file)

## READING DATA
print("now reading in the data ...")
mapfile <- fread(snp_map)
names(mapfile) <- c("Chromosome", "SNP.names","cM","Position")

snpfile <- fread(genotype_file)
snpfile <- select(snpfile, -c(FID,PAT,MAT,SEX,PHENOTYPE)) 

phenos <- fread(phenotype_file)

gc()

## prepare for gData
snpfile <- as.data.frame(snpfile)
rownames(snpfile) <- snpfile[["IID"]]
vec <- colnames(snpfile) != "IID"
snpfile <-snpfile[,vec]
colnames(snpfile) <- mapfile$SNP.names

mapfile <- as.data.frame(mapfile)
rownames(mapfile) <- mapfile[["SNP.names"]]
colnames(mapfile)[match(c("Chromosome", "Position"), colnames(mapfile))] <- c("chr", "pos")


## create gData object
gDataDrops <- createGData(geno = snpfile, map = mapfile)

gc()

## add phenotypes and covariates
phenotypes <- phenos[,c("id",trait), with = FALSE]
names(phenotypes)[1] <- "genotype"
phenotypes <- as.data.frame(phenotypes)
phenotypes[,trait] <- as.numeric(phenotypes[,trait])

if(systematic_effects != "") {

  covariates <- select(phenos, all_of(systematic_effects_vec))
  covariates <- as.data.frame(covariates)
  rownames(covariates) <- phenos$sample_id ## !! careful with the name of the sample ID column !!
} else covariates = NULL

gDataDrops <- createGData(gData = gDataDrops, pheno = phenotypes, covar = covariates)
# gDataDrops <- createGData(gData = gDataDrops, pheno = phenotypes)

gc()

##### recoding and cleaning
gDataDropsDedup <- codeMarkers(gDataDrops, impute = FALSE, verbose = TRUE, MAF = 0.01) 
gc()

#############
## GWAS
#############
GWASDrops <- runSingleTraitGwas(gData = gDataDropsDedup,
                                kinshipMethod = "astle",
                                traits = trait,
                                covar = systematic_effects_vec,
                                thrType = "fdr",
                                pThr = 0.01)

print(head(GWASDrops$GWAResult), row.names = FALSE)
# GWASDrops$signSnp
# GWASDrops$kinship[1:10,1:10]
# GWASDrops$thr
print(GWASDrops$GWASInfo)

fname <- paste(output_path,"/",dataset,"_",trait_label,"_GWAS_statgenGWAS.results", sep="")
fwrite(x = GWASDrops$GWAResult, file = fname)
gzip(fname, destname=sprintf("%s.gz", fname), overwrite = TRUE, remove = TRUE, BFR.SIZE = 1e+06)

gc()

## summary and plots
summary(GWASDrops)

plot(GWASDrops, plotType = "qq", trait = "phenotype")
plot(GWASDrops, plotType = "manhattan", trait = "phenotype", yThr = 3)

gc()
