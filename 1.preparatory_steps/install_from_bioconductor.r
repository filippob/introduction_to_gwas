## from Bioconductor
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager", repos='http://cran.us.r-project.org') ## OK (Oscar):
# BiocManager::install()

if (!require("biomaRt")) BiocManager::install("biomaRt") ## OK (Oscar)
if (!require("snpStats")) BiocManager::install("snpStats")
BiocManager::install("qvalue")
# BiocManager::install("gwasurvivr")

