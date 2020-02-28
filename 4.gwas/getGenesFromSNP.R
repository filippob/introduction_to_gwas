##############################################################
## SCRIPT TO READ DATA AND FIND GENES CLOSE TO SNP (FROM GWAS)
##############################################################

# if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
# BiocManager::install("biomaRt")

library("plyr")
library("biomaRt")
library("ggplot2")
library("data.table")

#############
# PARAMETERS
#############
ensembl_dataset = "btaurus_gene_ensembl"
# ensembl_dataset = "cfamiliaris_gene_ensembl"
window = 250000 # number of bases to search upstream and downstream the SNP position
input_file_name = "gwas_results.csv"

print("Current parameters:")
print(paste("ensembl dataset:",ensembl_dataset))
print(paste("window size:",window))
print(paste("input file:",input_file_name))

####################################################
## READ DATA AND FIND GENES CLOSE TO SNP (FROM GWAS)
####################################################
# ensembl=biomaRt::useMart("ensembl")
# datasets <- biomaRt::listDatasets(ensembl, verbose = TRUE) # show all the possible databases on Ensembl
# ensembl = biomaRt::useEnsembl(biomart="ensembl",dataset=ensembl_dataset)

print("connect to the ensembl database (this can take a while ... )")
ensembl = biomaRt::useMart("ensembl",dataset=ensembl_dataset)

## listAttributes(ensembl) # show the attributes of the database
attributes <- listAttributes(ensembl)  # show the attributes of the database

### READ DATA ##
## text file with snp name/id, chromosome, position (bps)

print("reading the input data")
# ch4 = fread(input_file_name)
ch4 <- data.frame("SNP"=c("BTA-46780-no-rs","snp2"),"CHROM"=c(2,2),"BP"=c(21670549,31670549))
rownames(ch4) <- ch4$SNP


## GET GENES
print("querying the database to get genes details (this can take a while ...)")
genes_ch4 = list()

for (snp_name in rownames(ch4)) {
  snp = ch4[snp_name,]
  genes_ch4[[snp_name]] = biomaRt::getBM(c('ensembl_gene_id',
                                  'entrezgene_id',
                                  'external_gene_name',
                                  'start_position',
                                  'end_position',
                                  'uniprotsptrembl',
                                  'uniprotswissprot'),  
                                filters = c("chromosome_name","start","end"),
                                values=list(snp$CHROM,snp$BP-window,snp$BP+window),
                                mart=ensembl)
}

# genes_ch4[[ch4$SNP]] # genes etc. retrieved for each SNP

#convert list to dataframe
print("convert list of genes to dataframe")
gwas_genes <- ldply(genes_ch4, function(x) {
  rbind.data.frame(x)
})

gwas_genes <- gwas_genes[!is.na(gwas_genes$external_gene_name) & gwas_genes$external_gene_name != "",]

## write out file
print("writing out genes to a file")
fwrite(gwas_genes,file = "gwas_genes.csv", sep = ",", col.names = TRUE)

print("DONE!")
