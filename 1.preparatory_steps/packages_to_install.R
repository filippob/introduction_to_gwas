## list of R packages to install for the course
## (some additional packages may still be needed during the course)

## from CRAN
install.packages("msm")
install.packages("doMC")
install.packages("nadiv")
install.packages("knitr")
install.packages("qqman")
install.packages("plotly")
install.packages("qvalue")
install.packages("genetics")
install.packages("snpStats")
install.packages("reshape2")
install.packages("ggfortify")
install.packages("tidyverse")
install.packages("patchwork")
install.packages("data.table")
install.packages("doParallel")
install.packages("tidymodels")
install.packages("RColorBrewer")



## from the github repository
install.packages("../software/gMatrix_0.2.tar.gz", repos = NULL, type = "source")
install.packages("../software/ldDesign_2.0-1.tar.gz", repos = NULL, type = "source")

## from Bioconductor
source("http://bioconductor.org/biocLite.R")

if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install()

BiocManager::install("biomaRt")

