### READ DATA ##
## text file with snp name/id, chromosome, position (bps)
library(RCurl)
x <- getURL("https://raw.githubusercontent.com/filippob/introduction_to_gwas/master/example_data/dogs_imputed.raw_cleft_lip_GWAS.results")

results = read.table(text = x,sep=",",header=T,colClasses = c("character","integer","integer","numeric"))
rownames(results) <- results$SNP

?p.adjust #Help and references for each of the methods

##Calculate different multiple correction methods
results$FDR<-p.adjust( results$P, method="fdr")
results$Bonferroni<-p.adjust( results$P, method="bonferroni" )
results$hochberg<-p.adjust( results$P, method="hochberg" )
results$hommel<-p.adjust( results$P, method="hommel" )
results$BY<-p.adjust( results$P, method="BY" )
results$BH<-p.adjust( results$P, method="BH" )



##Calculate Bonferroni correction P-value
Bonf<-0.05/dim(results)[1]
print(paste("The significant p-value after Bonferroni correction is",Bonf,sep=" "))

#Filter significant SNPs based on FDR
fdr<-max(results$P[which(results$FDR<0.05)])
print(paste("The significant p-value after FDR correction is",fdr,sep=" "))

#qqplot for the p-values
qqnorm(results$P, pch = 1, frame = FALSE)
qqline(results$P, col = "steelblue", lwd = 2)
points(seq(-4,3.9999,8/length(results$Bonferroni)) ,sort(results$Bonferroni), col = "red", cex=0.4,lwd = .2)
