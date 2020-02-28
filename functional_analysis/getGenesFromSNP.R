##############################################################
## SCRIPT TO READ DATA AND FIND GENES CLOSE TO SNP (FROM GWAS)
##############################################################

 if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
 BiocManager::install("biomaRt")

library("plyr")
library("biomaRt")
library("ggplot2")

#############
# PARAMETERS
#############
ensembl_dataset = "cfamiliaris_gene_ensembl"
window = 100000 # number of bases to search upstream and downstream the SNP position
input_file_name = "../data/dogs_imputed.raw_cleft_lip_GWAS.results"

####################################################
## READ DATA AND FIND GENES CLOSE TO SNP (FROM GWAS)
####################################################
ensembl=biomaRt::useMart("ensembl")
datasets <- biomaRt::listDatasets(ensembl, verbose = TRUE) # show all the possible databases on Ensembl
ensembl = biomaRt::useEnsembl(biomart="ensembl",dataset=ensembl_dataset)

## listAttributes(ensembl) # show the attributes of the database
attributes <- listAttributes(ensembl)  # show the attributes of the database

### READ DATA ##
## text file with snp name/id, chromosome, position (bps)
results = read.table("dogs_imputed.raw_cleft_lip_GWAS.results",sep=",",header=T,colClasses = c("character","integer","integer","numeric"))
rownames(results) <- results$SNP
results <- results[results$P<0.001,]
genes = list()

for (snp_name in rownames(results)) {
  snp = results[snp_name,]
  genes[[snp_name]] = biomaRt::getBM(c('ensembl_gene_id',
                              'entrezgene_id',
                              'external_gene_name',
                              'start_position',
                              'end_position',
                              'uniprotsptrembl',
                              'uniprotswissprot'),  
                            filters = c("chromosome_name","start","end"),
                            values=list(snp$CHR,snp$BP-window,snp$BP+window),
                            mart=ensembl)
}



## GET GENES


#convert list to dataframe
gwas_genes <- ldply(genes, function(x) {
  rbind.data.frame(x)
})

gwas_genes <- gwas_genes[!is.na(gwas_genes$external_gene_name) & gwas_genes$external_gene_name != "",]
gwas_genes <- do.call(rbind,genes)$external_gene_name

View(gwas_genes)
gwas_genes <-unique(gwas_genes)

## write out file
write.table(gwas_genes,file = "gwas_genes.csv", sep = ",", col.names = FALSE,row.names = FALSE, quote=FALSE)
