## Rscript to run a multi-locus GWAS
## the R implementation of the Blink software is used
## a more complete and flexible C++ version of Blink is available: https://github.com/Menggg/BLINK

# library("devtools")
# devtools::install_github("YaoZhou89/BLINK")


###################
## SET UP
###################
library("BLINK")
library("qqman")
library("tidyverse")
library("data.table")

source("http://zzlab.net/GAPIT/gapit_functions.txt")
source("http://zzlab.net/FarmCPU/FarmCPU_functions.txt")

mapf = "rice/rice_blink.map"
genof = "rice/rice_blink.mat"
phenof = "rice/phenotypes.txt"
covf = "rice/covariates.txt"

################
## RICE DATA
################
rice_map = read.table(mapf, head=TRUE)
rice_geno = read.big.matrix(genof, head=FALSE,sep="\t",type="char")
rice_y = read.table(phenof, head = TRUE)
rice_cov = as.matrix(fread(covf, header = FALSE))


writeLines(" - running Blink (multi-locus GWAS model)")
rice_blink = Blink(Y=rice_y, GD=rice_geno, GM=rice_map, CV=rice_cov, maxLoop=10, time.cal=TRUE)

##################
## GET RESULTS
##################
res = dplyr::select(rice_blink$GWAS, c(rs,chr,pos,`P.value`))
names(res) <- c("SNP","CHR","BP","P")

res = mutate(res, P = -log10(P))

png("rice/blink_manhattan.png")
qqman::manhattan(res, suggestiveline = TRUE, col = c("red","blue"), genomewideline = FALSE, logp = FALSE, width = 800, height = 600, res = 100)
dev.off()

# convert -log(p) back to p-values
p <- 10^((-res$P))
png("rice/blink_qqplot.png")
qqman::qq(p)
dev.off()

print("DONE!!")
