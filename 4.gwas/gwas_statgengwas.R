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

# genotype_file = "introduction_to_gwas/8.collaborative_exercise/pigs_imputed.raw"
# snp_map = "introduction_to_gwas/8.collaborative_exercise/pigs_imputed.map"
# phenotype_file = "introduction_to_gwas/data/pigs_phenotypes.txt"
# trait = "phenotype"
# trait_label = "stump_tail_sperm"
# systematic_effects = NULL

print(paste("genotype file name:",genotype_file))
print(paste("SNP map:",snp_map))
print(paste("phenotype file name:",phenotype_file))
print(paste("trait:",trait))
print(paste("trait label:",trait_label))
systematic_effects = if(exists(x = "systematic_effects")) systematic_effects else NULL
print(paste("systematic effects:",systematic_effects))

if(!is.null(systematic_effects) ) {
  
  systematic_effects_vec = strsplit(systematic_effects, split = ",")[[1]]
} else systematic_effects_vec = NULL

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
print("prepare object of class gData ... ")
snpfile <- as.data.frame(snpfile)
rownames(snpfile) <- snpfile[["IID"]]
vec <- colnames(snpfile) != "IID"
snpfile <-snpfile[,vec]
colnames(snpfile) <- mapfile$SNP.names

mapfile <- as.data.frame(mapfile)
rownames(mapfile) <- mapfile[["SNP.names"]]
colnames(mapfile)[match(c("Chromosome", "Position"), colnames(mapfile))] <- c("chr", "pos")


## create gData object
gData_gwas <- createGData(geno = snpfile, map = mapfile)

gc()

## add phenotypes and covariates
print("read phenotype file ...")
phenotypes <- phenos[,c("id",trait), with = FALSE]
names(phenotypes)[1] <- "genotype"
phenotypes <- as.data.frame(phenotypes)
phenotypes[,trait] <- as.numeric(phenotypes[,trait])

if(!is.null(systematic_effects)) {

  covariates <- select(phenos, all_of(systematic_effects_vec))
  covariates <- as.data.frame(covariates)
  rownames(covariates) <- phenos$sample_id ## !! careful with the name of the sample ID column !!
} else covariates = NULL

## create gData with both genotype and phenotype
gData_gwas <- createGData(gData = gData_gwas, pheno = phenotypes, covar = covariates)

gc()

##### recoding and cleaning
gData_gwas_clean <- codeMarkers(gData_gwas, impute = FALSE, verbose = TRUE, MAF = 0.01) 
gc()

#############
## GWAS
#############
GWAS_res <- runSingleTraitGwas(gData = gData_gwas_clean,
                                kinshipMethod = "astle",
                                traits = trait,
                                covar = systematic_effects_vec,
                                thrType = "fdr",
                                pThr = 0.01)

print(head(GWAS_res$GWAResult), row.names = FALSE)
print(GWAS_res$GWASInfo)

fname <- paste(dataset,trait_label,"GWAS_statgengwas.results", sep="_")
fwrite(x = GWAS_res$GWAResult, file = fname)
gzip(fname, destname=sprintf("%s.gz", fname), overwrite = TRUE, remove = TRUE, BFR.SIZE = 1e+06)

gc()

## summary and plots
summary(GWAS_res)

png(paste(dataset,trait_label,"qq_statgen.png",sep="_"))
plot(GWAS_res, plotType = "qq", trait = "phenotype")
dev.off()

png(paste(dataset,trait_label,"manhattan_statgen.png",sep="_"))
plot(GWAS_res, plotType = "manhattan", trait = "phenotype", yThr = 3)
dev.off()

gc()
