## script to prepare the sheep data (Kijas et al.) for the GWAS pipeline

library("data.table")

## read from command line
args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
}


phenotype_file= args[1]

print(paste("phenotype file name:",phenotype_file))
# phenotype_file = "2497_indiv_phenotype.txt"

phenotypes <- fread(phenotype_file)
phenotypes <- phenotypes[,c("Progeny","clutch","egg","lay")]
names(phenotypes)[1] <- "id"

phenotypes <- phenotypes[order(phenotypes$id, decreasing=TRUE),]
phenotypes <- phenotypes[!duplicated(phenotypes$id),]
phenotypes <- phenotypes[order(phenotypes$id, decreasing=FALSE),]

phenotypes$family <- phenotypes$id
phenotypes <- phenotypes[,c("id","family","clutch")]
phenotypes <- na.omit(phenotypes)

write.table(x = phenotypes[,c("family", "id")],
            file = "ids",
            col.names = FALSE,
            row.names = FALSE,
            quote = FALSE)

write.table(x = phenotypes, 
            file = "parus_phenotypes.txt",
            col.names = TRUE,
            row.names = FALSE,
            quote = FALSE)
