#########################################################
## WARNING: TO INSTALL ONLY IF NEEDED !!
#########################################################

### dependencies to catch-up from R3 to R4

# Package names
packages <- c("ps", "fs", "colorspace", "fansi", "Rcpp", 
              "R6", "munsell", "scales", "utf8", "generics", "assertthat", 
              "gtable", "cellranger", "stringr", "backports", "readxl",
              "lattice", "farver", "labeling", "crayon")

# Install packages not yet installed [UNCOMMENT TO RUN]
#installed_packages <- packages %in% rownames(installed.packages())
#if (any(installed_packages == FALSE)) {
#  install.packages(packages[!installed_packages], repos='http://cran.us.r-project.org')
#}


