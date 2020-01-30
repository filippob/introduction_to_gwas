
## general packages for data handling
library("knitr")
library("tidyr")
library("dplyr")
library("ggplot2")
library("ggfortify")
library("doParallel")
library("data.table")

## For the script gwas.r (GWAS with the kinship matrix)
library("msm")
library("doMC")
library("nadiv")

## own-made R package for G-matrix
library("gMatrix")

## GWAS and plots
library("qqman")
library("snpStats")

install.packages("doParallel")
install.packages("software/gMatrix_0.1.tar.gz", repos = NULL, type = "source")

source("http://bioconducor.org/biocLite.R")

if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install()
