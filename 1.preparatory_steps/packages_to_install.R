## list of R packages to install for the course
## (some additional packages may still be needed during the course)

## from the github repository (to be installed after cloning the repo)
install.packages("../software/gMatrix_0.2.tar.gz", repos = NULL, type = "source") ## OK (filippo): the source file is in software/
install.packages("../software/ldDesign_2.0-1.tar.gz", repos = NULL, type = "source")
install.packages("../software/nloptr_1.2.2.tar.gz", type = "source", repos = NULL)
#install.packages("../software/GenABEL.data_1.0.0.tar.gz", repos = NULL, type = "source")
#install.packages("../software/GenABEL_1.8-0.tar.gz", repos = NULL, type = "source")

## from Bioconductor
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install()

BiocManager::install("biomaRt")
BiocManager::install("snpStats")
BiocManager::install("qvalue")


## doMC
install.packages("doMC", repos="http://R-Forge.R-project.org")

## from github
library("devtools")
devtools::install_github("YaoZhou89/BLINK")

## from CRAN
install.packages("car")
install.packages("AER")
install.packages("msm")
install.packages("here") ## OK (filippo)
install.packages("nnet")
install.packages("MASS")
install.packages("afex") ## OK (filippo)
install.packages("dplyr") ## OK (filippo)
install.packages("nadiv")
install.packages("knitr") ## OK (filippo)
install.packages("qqman") ## OK (filippo)
install.packages("plotly") ## OK (filippo)
install.packages("Matrix")
install.packages("rrBLUP") ## OK (filippo)
install.packages("lmtest") ## OK (filippo)
install.packages("sommer")
install.packages("ggplot2") ## OK (filippo)
install.packages("R.utils") ## OK (filippo)
install.packages("genetics")
install.packages("survival")
install.packages("reshape2")
install.packages("prettydoc")
install.packages("patchwork")
install.packages("ggfortify") ## OK (filippo)
install.packages("tidyverse")
install.packages("patchwork")
install.packages("survminer")
install.packages("data.table") ## OK (filippo) 
install.packages("doParallel")
install.packages("tidymodels") ## OK (filippo)
install.packages("statgenGWAS") ## OK (filippo)
install.packages("RColorBrewer")




