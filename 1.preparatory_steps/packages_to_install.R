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
install.packages("R.utils")
install.packages("genetics")
install.packages("survival")
install.packages("snpStats")
install.packages("reshape2")
install.packages("ggfortify")
install.packages("tidyverse")
install.packages("patchwork")
install.packages("survminer")
install.packages("data.table")
install.packages("doParallel")
install.packages("tidymodels")
install.packages("statgenGWAS")
install.packages("RColorBrewer")



## from the github repository
install.packages("../software/gMatrix_0.2.tar.gz", repos = NULL, type = "source")
install.packages("../software/ldDesign_2.0-1.tar.gz", repos = NULL, type = "source")
install.packages("../software/GenABEL.data_1.0.0.tar.gz", repos = NULL, type = "source")
install.packages("../software/software/GenABEL_1.8-0.tar.gz", repos = NULL, type = "source")

## from Bioconductor
source("http://bioconductor.org/biocLite.R")

if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install()

BiocManager::install("biomaRt")

