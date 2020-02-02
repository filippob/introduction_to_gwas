#Demonstrating the use of KNN to impute missing SNP genotypes

##############
## FUNCTIONS
##############

### hamming distances
Hamming <- function(ssr_data) {
  
  z <- matrix(0, nrow = nrow(ssr_data), ncol = nrow(ssr_data))
  
  for (k in 1:(nrow(ssr_data) - 1)) {
    for (l in (k + 1):nrow(ssr_data)) {
      z[k, l] <- sum(ssr_data[k, ] != ssr_data[l, ], na.rm=TRUE)
      z[l, k] <- z[k, l]
    }
  }
  
  return(z)
}

### rescaling D
rescale_D <- function(dist_matrix, min=0, max=1) {
  
  scaled_D <- scales::rescale(dist_matrix,to=c(min,max))
  
  return(as.matrix(scaled_D))
}

### multidimensional scaling
mdscale <- function(dist_matrix,k=3,eig=TRUE) {
  
  D <- as.dist(dist_matrix)
  mdsD <- cmdscale(D, eig=eig, k=k)
  mdsD <- as.data.frame(mdsD$points)
  names(mdsD)[1:3] <- c("dim1","dim2","dim3")
  
  return(mdsD)
}

### plot mds
plot_mds <- function(mds_dimensions, ssr_data, dimA="dim1", dimB="dim2", savePlot=FALSE,
                     outputName=NULL, labels=FALSE, custom_colours = NULL) {
  
  mds_dimensions$status <- ssr_data$GROUP
  rownames(mds_dimensions) <- rownames(ssr_data)
  p <- ggplot(mds_dimensions,aes_string(x=dimA, y=dimB))
  
  if(labels) {
    
    p <- p + geom_text(aes(colour=factor(status), label = rownames(mds_dimensions)), size=3)
    
  } else {
    
    p <- p + geom_point(aes(colour=factor(status)))
  }
  p <- p + labs(colour = "Group") + ggtitle("MDS of SSR-based distances")
  if(!is.null(custom_colours)) p <- p + scale_color_manual(values = custom_colours)
  
  if(savePlot) {
    if (! is.null(outputName)) {
      fileNameOutput <- paste(outputName, "MDS","pdf", sep=".")
    } else {
      fileNameOutput <- paste(ssr_data, "MDS", 'pdf',sep=".")
    }
    ggsave(filename = fileNameOutput , plot = p, device = "pdf")
  } else {
    print(p)
  }
}

### imputation
impute_genotypes <- function(ped_file,dist_matrix,k=3) {
  
  samples <- ped_file$V2
  groups <- ped_file$V1
  
  ped_file$V1 <- NULL
  ped_file$V2 <- NULL
  ped_file$V3 <- NULL
  ped_file$V4 <- NULL
  ped_file$V5 <- NULL
  ped_file$V6 <- NULL
  
  nSNP <- ncol(ped_file)
  nInd <- nrow(ped_file)
  
  imputedM <- matrix(rep(NA,nInd*nSNP),nrow=nInd)
  
  print(paste(nSNP/2,"SNPs and",nInd,"samples",sep=" "))
  
  for(i in 1:ncol(ped_file)) {
    
    print(paste("SNP n.",i,sep=" "))
    X <- ped_file[,-i] #global matrix of features (train + test sets)
    y <- ped_file[,i]
    names(y) <- samples
    k <- k
    
    if(sum(is.na(y))<1) {
      
      imputedM[,i] <- y
    } else {
      
      yy <- outer(y,y,FUN=function(x,z) as.integer(ifelse(is.na(x==z),FALSE,x!=z)))
      D <- (dist_matrix-yy)
      row.names(D) <- names(y)
      colnames(D) <- names(y)
      
      testIDS <- names(y[is.na(y)])
      trainIDS <- names(y[!is.na(y)])
      
      if(length(testIDS)!=1) {
        
        NN <- apply(D[as.character(testIDS),as.character(trainIDS)],1,order)
        NN <- t(NN)
        ids <- row.names(NN) #for the output file
        
        ergebnisse <- apply(NN[,1:k, drop=F], 1, function(nn) {
          tab <- table(y[trainIDS][nn]);
          maxClass <- names(which.max(tab))
          pred <- maxClass;
          return(pred)
        })
        y[testIDS] <- ergebnisse[testIDS]
      } else {
        
        n <- order(D[testIDS,trainIDS])[1:k]
        tab <- table(y[trainIDS][n]);
        maxClass <- names(which.max(tab))
        prob <- tab[maxClass]/k;
        pred <- maxClass;
        y[testIDS] <- pred
      }
      
      imputedM[,i] <- y
    }
  }
  
  colnames(imputedM) <- colnames(ped_file)
  M <- cbind.data.frame(imputedM,"GROUP"=groups)
  rownames(M) <- samples
  
  # write.table(M,file="imputedM.csv",col.names=TRUE,row.names=FALSE,quote=FALSE,sep=",")
  
  return(M)
}


##################################################
##################################################
library("dplyr")
library("ggplot2")#]]
library("data.table")

## run as: Rscript --vanilla knni.R dogs_chr25.ped

## read from command line
args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
}

# ped_file = "dogs_chr25.ped"

ped_file= args[1]
print(paste("ped file name:",ped_file))

#"READ IN THE DATA"
M <- fread(ped_file, stringsAsFactors = FALSE, colClasses = c("character"))
# M <- fread("/home/ubuntu/data/rice_reduced.ped")
M[M==0] <- NA
M0 <- M[,.(V1,V2)]
names(M0) <- c("GROUP","ID")

na_count <- M %>%
  select(-c(V1,V2,V3,V4,V5,V6)) %>%
  summarise_all(funs(sum(is.na(.)))) %>%
  summarise(somma=sum(.))

n_samples <- nrow(M)
n_snps <- ncol(M)-6

na_count/(n_snps*n_samples)

### Step-by-step KNN implementation

#calculate distance matrix and nearest neighbours
# D <- Hamming(M[,-c(1:6)])
load("hamming.RData") ## load pre-calculated Hamming distances

## rescale distances
rescaled_D <- rescale_D(D)

## heatmap of distance matrix
pdf("heatmap_knni.pdf")
heatmap(D)
dev.off()

## MDS
mdsD <- mdscale(D)
pdf("mds.pdf")
plot_mds(mdsD,M0,dimA = "dim1", dimB = "dim2")
dev.off()

## IMPUTATION
impM <- impute_genotypes(ped_file = as.data.frame(M), dist_matrix = rescaled_D, k = 3)
fwrite(impM,file="knn_imputed_data.csv")

## try out different k values
