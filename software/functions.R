###############################################################################################
# FUNCTIONS
###############################################################################################
#function to generate the vector of indexes for artificial missing genotypes (to be save out as text file)
getIndexVector <- function(n,m,p=proportionMissing) {
  
  vec <- rep(FALSE,n*m)
  #now we randomly sample some artificial missing "genotypes" 
  idx <- sample(length(vec),p*(n*m))
  vec[idx] <- TRUE #use the randomly sampled indexes to set some of the FALSEs to TRUE
  return(which(vec))
}


#function to set some genotypes to missing as specified by getIndexVector()
#method of using odd and even column indexes
setToMissing_colInds <- function(ped,inds) {
  
  n <- nrow(ped)
  m <- ncol(ped)/2
  vec <- rep(FALSE,n*m)
  vec[inds] <- TRUE
  
  #this vector is now used to create a n*m matrix of TRUE/FALSE (TRUEs to be set to missing)
  missing <- matrix(vec,nrow=n,byrow = TRUE)
  
  #now we get the indexes of the missing cells
  idx <- which(missing, arr.ind = TRUE)
  
  #now we work on the indexes to convert (n*m) to (n*2m)
  seq_odd <- seq(1,(ncol(ped)-1),by=2) #index of odd column indexes (original ped-6)
  seq_even <- seq(2,ncol(ped),by=2) #index of even column indexes (original ped-6)
  
  #we create a matrix with all the index pairs for the ped-6 file
  idx2 <- cbind(rep(idx[,"row"],2),c(seq_odd[idx[,"col"]],seq_even[idx[,"col"]]))
  
  #we use the indexes to set some genotypes to missing 
  ped[idx2] <- NA
  return(ped)
}

#function to set some genotypes to missing as specified by getIndexVector()
#method of doubling the missing matrix
setToMissing_doubleM <- function(ped,inds) {
  
  n <- nrow(ped)
  m <- ncol(ped)/2
  vec <- rep(FALSE,n*m)
  vec[inds] <- TRUE
  
  #matrix of missing values
  missing <- matrix(vec,nrow = n, byrow = TRUE)
  
  # (n*m) --> (n*2m) TO let it known that the m is actually 2 columns per SNP 
  missing <- missing[,rep(1:ncol(missing),rep(2,ncol(missing)))]
  
  #assign missing to NAs
  ped[missing] <- NA
  return(ped)
}

#######################
### For parseResults.R
#######################
## function to extract genotypes from a .raw Plink file, corresponding to indexes in a vector
retrieveGenotypes <- function(rawPed,idx) {
  
  if(all(c("FID","IID","PAT","MAT","SEX","PHENOTYPE") %in% names(rawPed))) rawPed <- rawPed[,7:ncol(rawPed)]
  #get n. of samples and markers
  n <- nrow(rawPed)
  m <- ncol(rawPed)
  
  vec <- rep(FALSE,n*m)
  vec[idx] <- TRUE
  
  M <- matrix(vec,nrow=n,byrow = TRUE)
  inds <- which(M, arr.ind = TRUE)
  
  genotypes <- rawPed[inds]
  return(genotypes)
}


##############
## Miscellanea
##############

#function to trim leading/trailing blanks
trim <- function (x) gsub("^\\s+|\\s+$", "", x)
