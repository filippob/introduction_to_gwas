library("data.table")

## Reading the .ped file in from the shared server folder 
##Ensure that R knows that the SNP calls are characters, otherwise will read T as TRUE etc
## run as: Rscript --vanilla injectMissing.R <pedfile> <proportionMissing> <outname>
#ped <- read.table("/storage/share/jody/data/cowSubset.ped", colClasses = c("character"), header = FALSE)

args = commandArgs(trailingOnly = TRUE)

print(paste("arg1: ",args[1],sep=" "))
print(paste("arg2: ", args[2],sep=" "))
# print(paste("arg3:",args[3],sep=" "))

pedFile = args[1]
proportionMissing = as.numeric(args[2])
outName = args[3]

# Informing the number of column and rows in the data
#My example for generating the random samples. The 6 removes the first 6 information columns of the ped
# the /2 takes into account that two columns is equal to one SNP (i.e. 2 alleles)

# load functions to inject missing
source("../software/functions.R")

## A check for the progress of the script
print("Reading in the ped file ...")
ped <- fread(pedFile, header = FALSE, colClasses = "character")

n <- nrow(ped)
m <- (ncol(ped)-6)/2

#A check for the progress
print(paste(n,"samples and",m,"markers were read from",pedFile,sep=" "))

ped6 <- ped[,1:6, with=FALSE]
ped <- ped[,7:ncol(ped), with = FALSE]

idx <- getIndexVector(n = n, m = m, p = proportionMissing)

print(paste("In total,",length(idx),"SNP genotypes are being set to missing",sep=" "))

# M <- setToMissing_doubleM(ped,idx)
M <- setToMissing_colInds(ped,idx)

##Adding the first 6 informative lines back to the .ped file 
ped <- cbind.data.frame(ped6,M)

print("Writing out the ped file with artificial missing genotypes...")
##Writing the .ped file back out to the wd  
fname = outName
fwrite(ped, file = outName, quote = FALSE, na = "0", col.names = FALSE, sep=" ")

## must also write out the indexes to know which SNPs were removed and used as 'missing' data/genotypes
# write.table(idx, file = "indexes.txt", quote = FALSE, na = "0", row.names = FALSE, col.names = FALSE)

print("DONE!!")
