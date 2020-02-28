
## general packages for data handling
install.packages(c("knitr", "tidyr", "dplyr", "ggplot2", "ggfortify", 
                   "doParallel", "data.table", "msm", "doMC", "nadiv",
                   "qqman", "snpStats", "rrBLUP","reshape2", "genetics",
                   "DMwR", "plotly", "RColorBrewer", "qvalue","patchwork"))


install.packages("../software/gMatrix_0.2.tar.gz", repos = NULL, type = "source")
install.packages("../software/ldDesign_2.0-1.tar.gz", repos = NULL, type = "source")

source("http://bioconductor.org/biocLite.R")

if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install()

BiocManager::install("biomaRt")

