## run as: Rscript --vanilla prep_dogpheno.R UCD_2014.tfam
library("data.table")

## read from command line
args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
}

# phenotype_file = "plantgrainPhenotypes.txt"
# group_reference_file = "rice_group.reference"
# trait = "PH"

phenotype_file= args[1]
print(paste("phenotype file name:",phenotype_file))


tfam <- fread(phenotype_file)
tfam$V6 <- tfam$V6-1
names(tfam) <- c("family","id","father","mother","sex","phenotype")

print("writing out file ...")
fwrite(x = tfam[,c("id","family","phenotype"), with=FALSE], file = "dogs_phenotypes.txt", sep = "\t")
