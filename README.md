# introduction_to_gwas

**Material for the course "Introduction to genome-wide association studies (GWAS)"**

Instructors: *Filippo Biscarini, Oscar Gonzalez-Recio, Christian Werner*

This course will introduce students, researchers and professionals to the steps needed to build an analysis pipeline for Genome-Wide Association Studies (GWAS). The course will describe all the necessary steps involved in a typical GWAS study, which will then be used to build a reusable and reproducible bioinformatics pipeline.

Each day the course will start at **14:00** and end at **20:00** (CET).
As a general rule, we'll have a longer break (30 minutes) at 16:00 and two shorter breaks (10-15 minutes) later on during the day (to be decided flexibly depending on the sessions). 

<!-- timetable: [here](https://docs.google.com/spreadsheets/d/1Cy8vBD6I_no8UPzYPU9bz7ASWyI3bc4Y9vcdr5S1TBw/edit#gid=0) -->

**day 1**

- Lecture 0	General Introduction / Overview of the course [Filippo, Oscar, Christian]
    - [0. General Introduction](slides/0_General_Introduction.pdf)
    - [GWAS workflow (short)](slides/GWAS_workflow_short.pdf)
- Lecture 1	GWAS overview: case studies / examples from literature [Oscar]
    - [1. GWAS Overview](slides/1_GWAS_overview.pdf)
- Lecture 2	Introduction to GWAS: Linkage disequilibrium and linear Regression [Oscar]
    - [2. Introduction to GWAS](slides/2_Introduction_to_GWAS.pdf)
- Lab 1 - Practicalities and set-up (server, github repo, R, etc) and description of datasets [Christian]
    - [Description of datasets](slides/Description_of_datasets.pdf)
- Lecture 3 - part 1 basic Linux and advanced R libraries [Christian]
    - [3. Linux and the Shell](slides/3_Linux_intro.pdf)
- Lab 2 - part 2 basic Linux and advanced R libraries [Christian]
    - [Linux cheatsheet](slides/Unix_cheatsheet.pdf)
    - [Introduction to the tidyverse]<!-- (slides/Tidyverse_Intro.html) -->
 - [Course manual](slides/gwasManual.pdf)
 - [GWAS workflow](slides/GWAS_Workflow.pdf)



**day 2**

- Lab 3 (demonstration) GWAS: basic models (linear and logistic regression) [Oscar]
    - [R code. Exercise on simple linear regression]
    - [Rmarkdown code. Exercise on simple logistic regression]
- Lecture 4 Exploratory Data Analysis & Data Pre-Processing [Christian]
    - [4. EDA & Data Pre-Processing]
- Lab 4 EDA practice [Christian]
- Lecture 5 Data Types & Formats [Christian]
    - [5. Introducing the exercise (+ light touch on RMarkdown, optional) [Filippo]
[10.2 Collaborative exercise]]
- Lab 5 data preprocessing: practice [Christian]
- Lecture 6 The multiple testing issue [Oscar]
    - [6. Multiple_testing]
- Lecture 7 GWAS: Statistical power, Population stratification and Experimental design [Oscar] 
    - [7. Power and PopStrat]
    - [R code. Exercise on statistical power]


**day 3**

- Lecture 8	Imputation of missing genotypes: theory [Christian]
    - [8. Imputation]
- Lab 6 - part 1 practical session on imputation (Beagle) [Christian]
- Lecture 9: KNN Imputation 
    - [9. KNN Imputation]
- Lab 7 (demonstration) KNNI imputation [Filippo]
    - [R code. knni.Rmd](3.imputation/knni.Rmd)
- Lab 8 GWAS: the stand-alone script(s) for the full model [Filippo]
- Lab 9 revising the steps involved in GWAS [Filippo]
    - [10.1 Revising the steps]
- Brief intermission:
    - [R code PCA & population strucutre]<!--(4.gwas/PCA_Screeplots.R) -->
- Lab 10 Introducing the exercise [Filippo]
    - [10.2 Collaborative exercise]
- Collaborative exercise: Let's build our own GWAS workflow on new data [Filippo, Oscar, Christian]
    - part 1: individual/group break-out sessions to give it a try independetly
    - part 2: whole-group revision of the exercise


**day 4**
- Lecture 11 Bioinformatics pipelines: a super-elementary introduction [Filippo]
    - [11 A bioinformatics pipeline for GWAS]
- Lab 11 Building a pipeline with Snakemake [Filippo]
- Lab 12 The GWAS pipeline for continuous phenotype [Filippo]
    - plug-in for mean or KNN imputation
- Lab 13 Let's build together the GWAS pipeline for binary phenotype (guided exercise) [Filippo]
- Discussion Q&A on building pipelines for GWAS [Filippo, Oscar, Christian]
- Lecture 12 A light touch on post-GWAS analysis. Inferring functionality [Oscar]
    - [slides]
    - [R code. Exercise on R, and FUMA]
    
**day 5**

- Lecture 13 GWAS model extensions: a primer on categorical traits and longitudinal data [Filippo]
    - [13.1 GWAS model extensions_Dominance]
    - [13.2 GWAS model extensions_Polyploids, optional]
    - [13.3 GWAS model extensions_trait_types]
    - [13.4 GWAS model extensions_multi-trait-locus, software]
    - [R code GWASpoly example for polyploid species, optional]
    - [R code GWAS for categorical traits]
    - [R code GWAS for categorical traits - examples]
    - [R code GWAS for longitudinal traits]
    - [R code GWAS for multi-trait and multi-locus models]

- Lecture 14 A glimpse on ROH-based alternative [Filippo, optional]
    - [14.ROH-based and resampling methods as alternative approaches]
- Kahoot quiz on what we learned about GWAS! [Filippo, Oscar, Christian]
- Conclusions and wrap-up discussion on GWAS [Filippo, Oscar, Christian]

## organization of the code for the practical sessions

1. preparatory_steps: download and prepare the data
2. preprocessing: filter the data
3. imputation: imputing missing genotypes
4. gwas: run the GWAS models
5. power_and_significance: designing GWAS experiments
6. steps: identifying the individual steps involved in a GWAS study
7. pipeline: assembling the individual steps into a bioinformatics pipeline for GWAS
8. collaborative exercise: trying out what we learnt on new data
