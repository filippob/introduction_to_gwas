library("dplyr")
library("ggplot2")
library("reshape2")
library("data.table")

setwd("2.pre-processing/")

## go to PLINK (terminal) - allele frequency commands

rice.frq <- fread("rice.frq")
rice.frq = na.omit(rice.frq)

rice.frq %>%
  summarise(avg_frq=mean(MAF), std_dev=sd(MAF), max_frq=max(MAF), min_frq=min(MAF))

rice.frq %>%
  group_by(CHR) %>%
  summarise(avg_frq=mean(MAF), std_dev=sd(MAF), max_frq=max(MAF), min_frq=min(MAF))

p <- ggplot(rice.frq, aes(MAF))
p <- p + geom_histogram(binwidth = 0.01)
p

p <- ggplot(rice.frq, aes(MAF, colour = as.factor(CHR)))
p <- p + geom_freqpoly(binwidth = 0.01)
p <- p + guides(colour=guide_legend(title="CHR"))
p

## add population information
rice_crossref <- fread("../cross_reference/rice_group.reference")
rice_crossref$oldfam <- rep("NF1", nrow(rice_crossref))
rice_crossref$oldid <- rice_crossref$id
rice_crossref <- rice_crossref %>%
  select(oldfam, oldid, population, id)

fwrite(x = rice_crossref, file = "update.ids", col.names = FALSE, sep = "\t")

## go to PLINK - stratified allele frequency commands

rice.frq <- fread("rice_pop.frq.strat")
# trait_label = "disease"
rice.frq %>%
  group_by(CLST) %>%
  summarise(avg_frq=mean(MAF), std_dev=sd(MAF), max_frq=max(MAF), min_frq=min(MAF))

p <- ggplot(rice.frq, aes(MAF))
p <- p + geom_histogram(binwidth = 0.01)
p <- p + facet_wrap(~CLST, scales = "free")
p

## dogs

dogs.frqx <- fread("dogs.frqx")
dogs.frqx %>%
  summarise(avg_hom = mean(`C(HOM A1)`+`C(HOM A2)`), 
            std_hom = sd(`C(HOM A1)`+`C(HOM A2)`),
            avg_het = mean(`C(HET)`),
            std_het = sd(`C(HET)`))

dogs.frqx %>%
  group_by(CHR) %>%
  summarise(avg_hom = mean(`C(HOM A1)`+`C(HOM A2)`), 
            std_hom = sd(`C(HOM A1)`+`C(HOM A2)`),
            avg_het = mean(`C(HET)`),
            std_het = sd(`C(HET)`))


## add case/control information

## go to PLINK
## ~/Downloads/plink --dog --file ../../data/dogs --freq case-control --allow-no-sex --out dogs

dogs.frq <- fread("dogs.frq.cc")

dogs.frq <- dogs.frq %>%
  rename(CASES = MAF_A, CONTROLS = MAF_U)

mdogs <- melt(dogs.frq, 
              id.vars = c("CHR","SNP","A1","A2","NCHROBS_A","NCHROBS_U"), 
              variable.name = "GROUP", 
              value.name = "MAF")

mdogs %>%
  group_by(GROUP) %>%
  summarise(avg_frq = mean(MAF, na.rm = TRUE))

mdogs %>%
  group_by(GROUP,CHR) %>%
  summarise(avg_frq = mean(MAF, na.rm = TRUE))

p <- ggplot(mdogs, aes(MAF, colour = as.factor(CHR)))
p <- p + geom_freqpoly(binwidth = 0.025)
p <- p + guides(colour=guide_legend(title="CHR"))
p <- p + facet_wrap(~GROUP, nrow = 2, scales = "free")
p

#####################################################
#####################################################

## MISSING RATE

## go to PLINK - missing rate commands

## exercise: write R code to make your own summary tables and plots on missing-rate in the rice or dogs datasets

