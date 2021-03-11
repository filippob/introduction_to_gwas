
# source("https://bioconductor.org/biocLite.R")
# biocLite("DOSE")
# biocLite("mygene")
# biocLite("ReactomePA")
# biocLite("KEGG.db")
# biocLite("clusterProfiler")

if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
# avail <- BiocManager::available()
BiocManager::version()
BiocManager::install("ReactomePA", lib="/home/filippo/R/x86_64-pc-linux-gnu-library/3.4")

library("plyr")
require("DOSE")
library("biomaRt")
library("ggplot2")
library("KEGG.db")
library("ReactomePA")
library("data.table")

#############
# PARAMETERS
#############
ensembl_dataset = "btaurus_gene_ensembl"
window = 250000 # number of bases to search upstream and downstream the SNP position

####################################################
## READ DATA AND FIND GENES CLOSE TO SNP (FROM GWAS)
####################################################
ensembl=biomaRt::useMart("ensembl")
datasets <- listDatasets(ensembl, verbose = TRUE) # show all the possible databases on Ensembl
ensembl = biomaRt::useEnsembl(biomart="ensembl",dataset=ensembl_dataset)

## listAttributes(ensembl) # show the attributes of the database
attributes <- listAttributes(ensembl)  # show the attributes of the database

# ch4 = read.table("Significant_snp_CH4.txt",sep="\t",header=T,row.names=1,colClasses = c("character","character","integer","character","character","integer","numeric"))
ch4 <- data.frame("SNP"=c("BTA-46780-no-rs","snp2"),"CHROM"=c(2,2),"BP"=c(21670549,31670549))
rownames(ch4) <- ch4$SNP

genes_ch4 = list()

for (snp_name in rownames(ch4)) {
  snp = ch4[snp_name,]
  genes_ch4[[snp_name]] = getBM(c('ensembl_gene_id',
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

genes_ch4[[ch4$SNP]] # genes etc. retrieved for each SNP

#convert list to dataframe
gwas_genes <- ldply(genes_ch4, function(x) {
  rbind.data.frame(x)
  })

gwas_genes <- gwas_genes[!is.na(gwas_genes$external_gene_name) & gwas_genes$external_gene_name != "",]

## write out file
fwrite(gwas_genes,file = "gwas_genes.csv", sep = ",", col.names = TRUE)


# head(gwas_genes)

#entr
## convert Bovine gene names/entrez ID to human entrez IDs
library("mygene")
ge <- as.data.frame(queryMany(gwas_genes, scopes="symbol", fields="entrezgene", species="human"))

head(ge)
ge <- ge$entrezgene[!is.na(ge$entrezgene)] # Human Entrez gene IDs 


##############
## GO analysis
##############
#GO Enrichment Analysis of a gene set. Given a vector of genes, 
#this function will return the enrichment GO categories after FDR control. <--ONLY ENTREZID-->
#CC=cellular component || BP= biological process || MF=molecular function 
#pAdjustMethod one of "holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr", "none"

keggGO <- enrichGO(gene=ge,pvalueCutoff=0.8,qvalueCutoff=0.8, ont = "BP",readable=T)
head(summary(keggGO))

png("GObarplot.png",width=1000,height=1500,units="px")
barplot(keggGO, drop=TRUE, showCategory=50)
dev.off()

# Pablobarplot.enrichResult(keggGO, drop=TRUE, showCategory=50)
png("GOdotplot.png",width=600,height=600,units="px")
dotplot(keggGO,colorBy="qvalue")
dev.off()

png("GOgene-netplot.png",width=800,height=800,units="px")
cnetplot(keggGO, categorySize = "qvalue", foldChange = ge)
dev.off()

#qqplot
library(qqman)

png("GOqqplots.png",width=800,height=800,units="px")
par(mfrow=c(2,1))
qq(keggGO@result$pvalue)
qq(keggGO@result$p.adjust)
dev.off()

## cell compartments
keggGO_CC <- enrichGO(gene=ge,pvalueCutoff=0.8,qvalueCutoff=0.8, ont = "CC",readable=T)
head(summary(keggGO_CC))

png("GO_CCbarplot.png",width=1000,height=1500,units="px")
barplot(keggGO_CC, drop=TRUE, showCategory=50)
dev.off()

png("GO_CCgene-netplot.png",width=1000,height=800,units="px")
cnetplot(keggGO_CC, categorySize = "qvalue", foldChange = ge)
dev.off()

## molecular function
keggGO_MF <- enrichGO(gene=ge,pvalueCutoff=0.8,qvalueCutoff=0.8, ont = "MF",readable=T)
head(summary(keggGO_MF))

png("GO_MFbarplot.png",width=1000,height=1500,units="px")
barplot(keggGO_MF, drop=TRUE, showCategory=50)
dev.off()

png("GO_MFgene-netplot.png",width=1000,height=800,units="px")
cnetplot(keggGO_MF, categorySize = "qvalue", foldChange = ge)
dev.off()



#groupGO Functional Profile of a gene set at specific GO level. 
#Given a vector of genes, this function will return the GO profile at a specific level.
#CC=cellular component || BP= biological process || MF=molecular function  
#level=?? Specific GO Level
ggo <- groupGO(gene=as.character(ge), organism="human", ont="CC", level=4, readable=TRUE)
head(summary(ggo),20)
barplot(ggo, drop=TRUE, showCategory=50)

###################
## PATHWAY ANALYSIS
###################
#KEGG Enrichment Analysis of a gene set. Given a vector of genes, 
#this function will return the enrichment KEGG categories with FDR control.

kgEnriched <- enrichKEGG(gene=ge,pvalueCutoff=0.8,qvalueCutoff=0.8, organism="hsa",readable=T)
summary(kgEnriched)
KEGG_INFO=as.data.frame(summary(kgEnriched))

png("keggEnriched_barplot.png",width=1000,height=800,units="px")
barplot(kgEnriched, showCategory=50)   #bar plot
dev.off()

png("keggPathWays.png",width=800,height=800,units="px")
cnetplot(kegg, categorySize="qvalue") #cluster Pathway
dev.off()

png("keggPathWaysGeneNum.png",width=800,height=800,units="px")
cnetplot(kegg, categorySize="geneNum",ge) #cluster Pathway
dev.off()

ggplot(KEGG_INFO, aes(as.factor(Description), colour=pvalue)) + geom_bar() + coord_flip()

#enrichMap

png("enrichMap.png",width=800,height=800,units="px")
MAPkegg <- enrichMap(kgEnriched,n=10,vertex.label.font = 1)
dev.off()

head(MAPkegg$edge_data)


#creazione file finale con tutti i pathway ma colorati solo i nostri
library("KEGGREST")
list_pathway=head(KEGG_INFO$ID)
query1 <- keggGet(c(list_pathway))
list_final=query1[[1]]$GENE

listPaths <- as.data.frame(list_final)

save(genes_ch4,ge,keggGO,keggGO_CC,keggGO_MF,ggo,kgEnriched,MAPkegg,listPaths, file="res.RData")

#TEST: how to subset list_final?
genePathway=head(KEGG_INFO$geneID)
query1 <- keggGet(c("hsa04975"))
list_final=query1[[1]]$GENE[c(FALSE,TRUE)]
list_final
b=as.data.frame(list_final)

write.table(b,file="b.txt",row.names = F,quote=FALSE, col.names=TRUE,sep = ';')

reactHome <- enrichPathway(gene=ge,pvalueCutoff=0.8,qvalueCutoff=0.8, organism="human",readable=T)
summary(reactHome)
