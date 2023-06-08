##############################################################
## SCRIPT TO READ DATA AND FIND GENES CLOSE TO SNP (FROM GWAS)
##############################################################

if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
BiocManager::install("biomaRt")

library("plyr")
library("biomaRt")
library("ggplot2")
library(RCurl)

#############
# PARAMETERS
#############
ensembl_dataset = "clfamiliaris_gene_ensembl"
window = 100000 # number of bases to search upstream and downstream the SNP position


####################################################
## READ DATA AND FIND GENES CLOSE TO SNP (FROM GWAS)
####################################################
ensembl=biomaRt::useMart("ensembl")
datasets <- biomaRt::listDatasets(ensembl, verbose = TRUE) # show all the possible databases on Ensembl
ensembl = biomaRt::useEnsembl(biomart="ensembl",dataset=ensembl_dataset,mirror="asia")

## listAttributes(ensembl) # show the attributes of the database
attributes <- listAttributes(ensembl)  # show the attributes of the database

### READ DATA ##
## text file with snp name/id, chromosome, position (bps)
input_file_name <- getURL("https://raw.githubusercontent.com/filippob/introduction_to_gwas/master/example_data/dogs_imputed.raw_cleft_lip_GWAS.results")
results = read.table(text=input_file_name,sep=",",header=T,colClasses = c("character","integer","integer","numeric"))
rownames(results) <- results$SNP
##Calculate FDR and filter SNPs
results$Padj<-p.adjust( results$P, method="fdr" )
#results$Padj<-p.adjust( results$P, method="bonferroni" )

##Calculate Bonferroni correction P-value
Bonf<-0.05/dim(results)[1]
print(paste("The significant p-value after Bonferroni correction is",Bonf,sep=" "))

#Filter significant SNPs based on Bonferroni
 ##results <- results[results$P<Bonf,]
#Filter significant SNPs based on FDR
fdr<-max(results$P[which(results$Padj<0.05)])
print(paste("The significant p-value after FDR correction is",fdr,sep=" "))

results <- results[results$Padj<fdr,]
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
write.table(gwas_genes,file = "gwas_genesCfamiliaris.csv", sep = ",", col.names = FALSE,row.names = FALSE, quote=FALSE)
