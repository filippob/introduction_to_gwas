
### Library
library("data.table")
library("factoextra")
library("rrBLUP")
library("tidyverse")

### Genoype marker matrix
genotypes <- fread(file = "../3.imputation/rice_imputed.raw")
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

### Principal Component Analysis
pca <- prcomp(grm, scale = TRUE, center = TRUE)

### Extract eigenvalues from PCA
eigenvalues <- pca$sdev^2

### Variances explained by first 8 principal components, respectively
round((eigenvalues/sum(eigenvalues)*100), 2)[1:8]

### Total variance explained by the first 1 - 8 principal components
for(i in 1:8){
  varExp <- (eigenvalues/sum(eigenvalues)*100)[1:i]
  print(paste0("Var explained by first ", i, " PCs: ", round(sum(varExp), 2), "%"))
}

### Scree plot
fviz_eig(pca, ncp = 8)

### Extract first 3 principal components which explain ~80% of the total variance
pc <- pca$rotation[,1:3]


### K-means clustering and comparison of within-cluster sum of squares
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


# K-means clusters showing the group of each individual
kCluster <- kmeans(pc, 4, nstart = 25)
kCluster$cluster

### Clusters based on first 2 principal components
fviz_cluster(kCluster, data = pc[, 1:2],
             #palette = c("#2E9FDF", "#00AFBB", "#E7B800"), 
             geom = "point",
             ellipse = FALSE,
             #ellipse.type = "convex", 
             ggtheme = theme_bw()
)


################# 3D PLOT ########################
pc_3 <- as.data.frame(pc)
pc_3$cluster <- as.factor(kCluster$cluster)

## 3D plot
library("plotly")

p <- plot_ly(data = pc_3, 
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
