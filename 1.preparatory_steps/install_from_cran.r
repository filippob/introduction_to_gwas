
## list of R packages to install for the course
## (some additional packages may still be needed during the course)

# Package names
packages <- c(
	      "data.table",
	      # "doMC", # only needed for software/gwas.r (old code that we are probably no longer using) 
	      "doParallel",
	      "dplyr",
	      "ggfortify",
	      "ggplot2", 
	      "readxl",  
	      "reshape2",
	      "rrBLUP",
	      "sommer",
	      "tidymodels",
	      "tidyr", 
	      "tidyverse",
	      "MASS", "scales", "nlme", "psych", "ordinal", 
	      "stringr", "assist", "magrittr", 
	      "msm", "nnet", "here", "nadiv","qqman", 
	      "Matrix", "R.utils", "genetics",
	      "prettydoc","patchwork","plyr",
	      "statgenGWAS","RColorBrewer"
	     )

packages_extensions <- c("AER",
	      "afex", 
	      "car", 
	      "ggfortify",
	      "ggpubr",
	      "lmtest", 
	      "plotly", 
	      "survival",
	      "survminer"
	     )

# Packages not yet installed (UNCOMMENT TO INSTALL!!)
installed_packages <- packages %in% rownames(installed.packages())

# Install packages not yet installed (UNCOMMENT TO INSTALL!!)
if (any(installed_packages == FALSE)) {
 install.packages(packages[!installed_packages], repos='http://cran.us.r-project.org', lib='/home/user1/Rpackages/') ## need to make sure the lib folder exists!
}


# Packages loading
# invisible(lapply(packages, library, character.only = TRUE))
