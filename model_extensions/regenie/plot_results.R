## Rscript to make plots with GWAS results

# -------------------------------------
# Reading File 1
# -------------------------------------
## read from command line
args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
}

# phenotype_file = "../introduction_to_gwas/6.steps/data/rice_phenotypes.txt"
# resf = "extensions/regenie/rice/rice_regenie_res_Y1.regenie"
resf = args[1]

print(paste("The GWAS results file to be read is:", basename(resf)))

### SET UP ###
library("qqman")
library("tidyverse")
library("data.table")

###########
### RESULTS
###########
res = fread(resf)
res = select(res, c(ID,CHROM,GENPOS,LOG10P))
names(res) <- c("SNP","CHR","BP","P")

print("writing out results and figures ...")
## manhattan plot
fname = file.path(dirname(resf),"manhattan.png")
png(fname)
manhattan(res, suggestiveline = TRUE, col = c("red","blue"),
          genomewideline = FALSE, logp = FALSE, width = 800, height = 600, res = 100)
dev.off()

# convert -log(p) back to p-values
p <- 10^((-res$P))

## qq-plot
fname = file.path(dirname(resf),"qqplot.png")
png(fname, width = 600, height = 600)
qq(p)
dev.off()
