library("tidyr")
library("dplyr")
library("ggplot2")

### Continuous trait
pheno_continuous <- read.table("../data/rice_phenotypes.txt", header = TRUE)

D <- pheno_continuous %>%
  group_by(population) %>%
  summarise(N=n(), avgPH=mean(phenotype), stdPH=sd(phenotype), minPH=min(phenotype),
            maxPH=max(phenotype))
D
## density plot
p <- ggplot(pheno_continuous, aes(x=phenotype)) + geom_density()
p <- p + xlab("plant height")
p

## density plot with average line
p <- ggplot(pheno_continuous, aes(x=phenotype)) + geom_density()
p <- p + geom_vline(aes(xintercept=mean(phenotype)), color="blue", linetype="dashed", size=1)
p <- p + xlab("plant height")
p

## density plot with color shades per population
p <- ggplot(pheno_continuous, aes(x=phenotype)) + geom_density(aes(fill=population), alpha=0.4)
p <- p + scale_fill_manual(values=c("#999999", "#E69F00", "#56B4E9","#FFE4B5"))
p <- p + xlab("plant height")
p

## density plot with color shades per population + histograms
p <- ggplot(pheno_continuous, aes(x=phenotype, color=population, fill=population))
p <- p + geom_histogram(aes(y=..density..), alpha=0.5, position="identity")
p <- p + geom_density(alpha=.2) 
p


## boxplots
p <- ggplot(pheno_continuous, aes(x=population,y=phenotype)) + geom_boxplot(aes(fill=population))
p <- p + xlab("population") + ylab("plant height")
p


### Binary trait
pheno_binary <- read.table("../data/dogs_phenotypes.txt", header = TRUE)

D <- pheno_binary %>%
  group_by(family, phenotype) %>%
  summarise(N=n()) %>%
  spread(key = phenotype, value = N)

D

## barplot
pheno_binary$phenotype <- as.factor(pheno_binary$phenotype)
p <- ggplot(pheno_binary, aes(x=phenotype)) + geom_bar(aes(fill=phenotype))
p

