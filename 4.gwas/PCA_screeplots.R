
### Install missing packages
install.packages(setdiff(
  c("data.table", "factoextra", "plyr", "rrBLUP", "ggplot2", "plotly"),
  rownames(installed.packages())
))


### Library
library(data.table)
library(factoextra)
library(plyr)
library(rrBLUP)
library(ggplot2)
library(plotly)

### Genoype marker matrix
genotypes <- fread(file = "rice_imputed.raw")
genotypes[1:5, 1:10]

rownames(genotypes) <- as.matrix(genotypes[,2])
genotypes <- genotypes[, -c(1:6)]
genotypes <- genotypes - 1
genotypes[1:5, 1:10]

### Calculate genomic relationship matrix (rrBLUP)
### Requires -1, 0, 1 coding (as done above)
grm <- A.mat(genotypes)


## First step to get an idea of subpopulation structure based on the relationship 
## captured in the genomic relationship matrix.
heatmap(grm,labRow = FALSE, labCol = FALSE, col=rev(heat.colors(75)))



##### PCA - 2 Options #####

### 1. Principal Component Analysis using the transpose of the genotype matrix.
### Function prcomp creates the covariance matrix. However, this is NOT the GRM,
### but the a simple covariance matrix between individuals based on marker genotypes.
### The GRM we created above uses a scaling explained by VanRaden (2008), which
### gives creates a relationship matrix with characteristics similar to the 
### pedigree-based numerator relationship matrix (NRM).
pca <- prcomp(t(genotypes), center = TRUE, scale = TRUE)  # scaling required if covariates have different units.

### Extract eigenvalues from PCA
eigenvalues <- pca$sdev^2

### Variances explained by first 8 principal components, respectively
round((eigenvalues/sum(eigenvalues)*100), 2)[1:8]

### Total variance explained by the first 1 - 8 principal components
for(i in 1:8){
  varExp <- (eigenvalues/sum(eigenvalues)*100)[1:i]
  print(paste0("Var explained by first ", i, " PCs: ", round(sum(varExp), 2), "%"))
}

### 1. Principal Component Analysis on GRM using single value decomposition ###
### This PCA is applied directly on the GRM, which uses the scaling by VanRaden (2008).
### We will use this method in the following steps.
svd <- svd(grm)

### Extract eigenvalues and eigenvectors
eigenvalues <- svd$d
eigenvectors <- svd$u

### Variances explained by first 8 principal components, respectively
var_explained <- round((eigenvalues/sum(eigenvalues)*100), 2)[1:8]
var_explained

### Total variance explained by the first 1 - 8 principal components
for(i in 1:8){
  varExp <- (var_explained)[1:i]
  print(paste0("Var explained by first ", i, " PCs: ", round(sum(varExp), 2), "%"))
}


### Scree plot
var_df <- data.frame(PC = c(1:8),
                     Var = var_explained)

var_df %>%
  ggplot(aes(x=PC,y=var_explained, group=1))+
  geom_point(size=2)+
  geom_line()+
  xlab("Principal Component") + 
  ylab("Variance explained (%)") +
  ggtitle("Scree Plot") +
  ylim(0, round_any(var_explained[1], 10, f = ceiling))

### Extract first 3 principal components which explain ~40% of the total variance
pc <- eigenvectors[,1:3]


### K-means clustering based on first 4 PC's and comparison of within-cluster sum of squares
### to identify sub-populations (eyeball method)
clusters <- 15 # max. number of clusters to compare
withinSS <- data.frame(nClusters = seq(1:clusters),
                       wss = NA)
for(i in 1:clusters){
  withinSS[i,2] <- sum(kmeans(pc, centers=i, nstart=25)$withinss)
} 

### The strongest bend in the graph indicates a suitable number of clusters 
### (eyeball method)
withinSS %>%
  ggplot(aes(x=nClusters,y=wss, group=1))+
  geom_point(size=2)+
  geom_line()+
  labs(title="Scree plot: within-cluster sum of squares")


# K-means clusters showing the group of each individual.
# Number of clusters is set to 4 based on heatmap and scree plot results.
kCluster <- kmeans(pc, 4, nstart = 25)
kCluster$cluster

### Clusters based on first 2 principal components
pc_df <- as.data.frame(pc)[1:3]
colnames(pc_df) <- paste0("PC", 1:3)

fviz_cluster(kCluster, data = pc_df[, 1:2],
             geom = "point",
             ellipse = FALSE,
             ggtheme = theme_bw()
)


################# 3D PLOT ########################
pc_3D <- pc_df
pc_3D$cluster <- as.factor(kCluster$cluster)

## 3D plot

p <- plot_ly(data = pc_3D, 
             x = ~PC1, y = ~PC2, z = ~PC3,
             type = "scatter3d",
             color = ~cluster) %>%
  add_markers() %>%
  layout(scene = list(xaxis = list(title = 'PC1'),
                      yaxis = list(title = 'PC2'),
                      zaxis = list(title = 'PC3')),
         annotations = list(
           x = 0.005,
           y = 0.01,
           text = 'Cluster',
           xref = 'paper',
           yref = 'paper',
           showarrow = FALSE
         ))

htmlwidgets::saveWidget(as_widget(p), "pca_plot_3d.html")
