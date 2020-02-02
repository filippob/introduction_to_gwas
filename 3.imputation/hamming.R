## script to compute matrix of Hamming distances
## Rscript --vanilla hamming.R ped_file

## packages
library("data.table")

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


## command line
args = commandArgs(trailingOnly = TRUE)

ped_file= args[1]
print(paste("ped file is",ped_file))

## start time
start.time <- Sys.time()

#"READ IN THE DATA"
#M <- fread(ped_file, na.strings = "0")
M <- fread(ped_file)
M[M==0] <- NA

n_samples <- nrow(M)
n_snps <- ncol(M)-6

print(paste("N. of samples: ", n_samples, "; N. of SNP: ", n_snps))

## Hamming
print("computing Hamming distances ...")
D <- Hamming(M[,-c(1:6)])

save(D, file = "hamming.RData")

## end time
end.time <- Sys.time()
time.taken <- end.time - start.time
print("Total time taken below")
print(time.taken)

print("DONE!")