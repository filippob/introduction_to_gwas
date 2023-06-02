
## list of R packages to install for the course
## (some additional packages may still be needed during the course)

# Package names
packages <- c("AER",
	      "afex", 
	      # "doMC", # only needed for software/gwas.r (old code that we are probably no longer using) 
	      "doParallel",
	      "dplyr",
	      "ggplot2", 
	      "ggpubr",
	      "readxl",  
	      "reshape2",
	      "tidymodels",
	      "tidyr", 
	      "tidyverse",
	      "car", "MASS", "scales", "nlme", "psych", "ordinal", 
	      "lmtest",  "stringr", "assist", "magrittr", 
	       "msm", "nnet", "here", "afex", "nadiv","qqman", "plotly", 
	      "Matrix", "rrBLUP", "sommer","R.utils", "genetics", "survival",
	      "prettydoc","patchwork","plyr","ggfortify","survminer","data.table",
	      "statgenGWAS","RColorBrewer"
	     )

# Packages not yet installed (UNCOMMENT TO INSTALL!!)
installed_packages <- packages %in% rownames(installed.packages())

# Install packages not yet installed (UNCOMMENT TO INSTALL!!)
if (any(installed_packages == FALSE)) {
 install.packages(packages[!installed_packages], repos='http://cran.us.r-project.org', lib='/home/user1/Rpackages/') ## need to make sure the lib folder exists!
}


# Packages loading
# invisible(lapply(packages, library, character.only = TRUE))
