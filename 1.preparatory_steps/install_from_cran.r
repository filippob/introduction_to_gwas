
## list of R packages to install for the course
## (some additional packages may still be needed during the course)

# Package names
packages <- c("ggplot2", "readxl", "dplyr", "tidyr", "reshape2", 
	      "car", "MASS", "scales", "nlme", "psych", "ordinal", 
	      "lmtest", "ggpubr", "stringr", "assist", "magrittr", "tidyverse",
	      "AER", "msm", "nnet", "here", "afex", "nadiv","qqman", "plotly", 
	      "Matrix", "rrBLUP", "sommer","R.utils", "genetics", "survival",
	      "prettydoc","patchwork","plyr","ggfortify","survminer","data.table",
	      "doParallel","tidymodels","statgenGWAS","RColorBrewer","doMC")

# Install packages not yet installed (UNCOMMENT TO INSTALL!!)
installed_packages <- packages %in% rownames(installed.packages())
#if (any(installed_packages == FALSE)) {
#  install.packages(packages[!installed_packages], repos='http://cran.us.r-project.org', lib='/home/user1/Rpackages/') ## need to make sure the lib folder exists!
#}


# Packages loading
# invisible(lapply(packages, library, character.only = TRUE))
