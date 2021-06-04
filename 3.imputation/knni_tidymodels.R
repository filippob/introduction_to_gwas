## R script to carry out KNN imputation using tidymodels
## kinship matrix used to account for population structure in the data
## input: Plink .raw file (matrix of 0s, 1s, 2s)
# run as Rscript --vanilla knni.R genotype_file=path_to_genotypes

library("tidymodels") #for kNN imputation
library("data.table")

print("KNN imputation of missing genotypes")

###################################
## read arguments from command line
###################################
allowed_parameters = c(
  'genotype_file'
)

args <- commandArgs(trailingOnly = TRUE)

print(args)
for (p in args){
  pieces = strsplit(p, '=')[[1]]
  #sanity check for something=somethingElse
  if (length(pieces) != 2){
    stop(paste('badly formatted parameter:', p))
  }
  if (pieces[1] %in% allowed_parameters)  {
    assign(pieces[1], pieces[2])
    next
  }
  
  #if we get here, is an unknown parameter
  stop(paste('bad parameter:', pieces[1]))
}

genotype_file = "introduction_to_gwas/3.imputation/dogs_chr25.raw"
print(paste("genotype file name:",genotype_file))
geno = fread(genotype_file)
matx = geno[,-c(1:6)]

print(paste("N. of missing SNP genotypes to be imputed:",sum(is.na(matx))))

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
rec <- recipe(missing_data) %>% 
  update_role(all_numeric(), new_role = "predictor")

ratio_recipe <- rec %>%
  step_impute_knn(all_predictors(), neighbors = 3)

ratio_recipe2 <- prep(ratio_recipe, training = missing_data, verbose = FALSE)
imputed = juice(ratio_recipe2)
imputed2 = bake(ratio_recipe2, missing_data)

rowSums(imputed == imputed2)/ncol(imputed) 


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
