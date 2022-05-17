# introduction_to_gwas

**Material for the Course "Introduction to genome-wide association studies (GWAS)"**

Instructors: *Filippo Biscarini, Oscar Gonzalez-Recio, Christian Werner*

This course will introduce students, researchers and professionals to the steps needed to build an analysis pipeline for Genome-Wide Association Studies (GWAS). The course will describe all the necessary steps involved in a typical GWAS study, which will then be used to build a reusable and reproducible bioinformatics pipeline.

Each day the course will start at **14:00** and end at **20:00** (CET).
As a general rule, we'll have a longer break (30 minutes) at 16:00 and two shorter breaks (10-15 minutes) later on during the day (to be decided flexibly depending on the sessions). 

<!-- timetable: [here](https://docs.google.com/spreadsheets/d/1Cy8vBD6I_no8UPzYPU9bz7ASWyI3bc4Y9vcdr5S1TBw/edit#gid=0) -->

**Day 1**

- Lecture 0	General Introduction / Overview of the Course [Filippo, Oscar, Christian]
    - [General Introduction](slides/0_General_Introduction.pdf)
    - [GWAS Workflow (short)](slides/GWAS_workflow_short.pdf)
- Lecture 1	GWAS Overview: Case Studies / Examples from Literature [Oscar]
    - [GWAS Overview](slides/1_GWAS_overview.pdf)
- Lecture 2	Introduction to GWAS: Linkage Disequilibrium and Linear Regression [Oscar]
    - [Introduction to GWAS](slides/2_Introduction_to_GWAS.pdf)
- Lecture 3 - Basic Linux and the Shell [Christian]
    - [Linux and the Shell](slides/3_Linux_intro.pdf)
- Lab 1 - Practicalities and Set-up (Server, github repo, R, etc) and Description of Datasets [Christian]
    - [Description of Datasets](slides/Description_of_datasets.pdf)
    - [Linux Cheatsheet](slides/Unix_cheatsheet.pdf)
    - [Introduction to the Tidyverse]<!-- (slides/Tidyverse_Intro.html) -->
 - [Course Manual](slides/gwasManual.pdf)
 - [GWAS Workflow](slides/GWAS_Workflow.pdf)



**Day 2**

- Lab 2 (Demonstration) GWAS: Basic Models (Linear and Logistic Regression) [Oscar]
    - [R code. Exercise on Simple Linear Regression]
    - [Rmarkdown Code. Exercise on Simple Logistic Regression]
- Lecture 4 Data Types & Formats [Christian]
    - [Common Data Types and Formats](slides/4_Data_types.pdf)
- Lecture 5 Initial Data Analysis, Exploratory Data Analysis and Data Pre-Processing [Christian]
    - [IDA, EDA & Data Pre-Processing](slides/5_Data_pre-processing.pdf)
- Lab 3 EDA & IDA [Christian]
- Lab 4 Data Pre-Processing [Christian]
- Lecture 6 The Multiple Testing Issue [Oscar]
    - [Multiple Testing](slides/6_Multiple_testing.pdf)
- Lecture 7 Statistical Power, Population Stratification and Experimental Design [Oscar] 
    - [Statistical Power and Population Stratification](slides/7_Experimental_design.pdf)
    - [R code. Exercise on statistical power]


**Day 3**

- Lecture 8	Imputation of Missing Genotypes [Christian]
    - [Imputation]
- Lab 5 Imputation of Missing Genotypes using Beagle [Christian]
- Lecture 9 KNN Imputation 
    - [KNN Imputation]
- Lab 6 (Demonstration) KNNI Imputation [Filippo]
    - [knni.Rmd](3.imputation/knni.Rmd)
    - [hamming.R](3.imputation/hamming.R)
    - [knni.R](3.imputation/knni.R)
    - [knni.sh](3.imputation/knni.sh)
- Lab 7 GWAS: The Stand-Alone Script(s) for the Full Model [Filippo]
- Lab 8 Revising the Steps involved in GWAS [Filippo]
    - [Revising the Steps]
- Brief Intermission:
    - [R code PCA & Population Strucutre]<!--(4.gwas/PCA_Screeplots.R) -->
- Lab 9 Introducing the Exercise [Filippo]
    - [Collaborative Exercise]
- Collaborative Exercise: let's build our own GWAS workflow on new data [Filippo, Oscar, Christian]
    - Part 1: Individual/Group Break-Out Sessions to give it a try independetly
    - Part 2: Whole-Group Revision of the Exercise


**Day 4**
- Lecture 10 Bioinformatics Pipelines: a super-elementary Introduction [Filippo]
    - [A bioinformatics pipeline for GWAS]
- Lab 10 Building a Pipeline with Snakemake [Filippo]
- Lab 11 The GWAS pipeline for Continuous Chenotypes [Filippo]
    - Plug-In for Mean or KNN Imputation
- Lab 12 The GWAS pipeline for Binary Phenotypes (Guided Exercise) [Filippo]
- Q&A on building Pipelines for GWAS [Filippo, Oscar, Christian]
- Lecture 11 A light Touch on Post-GWAS Analysis: Inferring Functionality [Oscar]
    - [slides]
    - [R code. Exercise on R, and FUMA]
    
**Day 5**

- Lecture 12 GWAS Model Extensions: a Primer on Categorical Traits and Longitudinal Data [Filippo]
    - [12.1 GWAS Model Extensions_Dominance]
    - [12.2 GWAS Model Extensions_Polyploids, optional]
    - [12.3 GWAS Model Extensions_Trait_Types]
    - [12.4 GWAS Model Extensions_Multi-Trait-Locus, software]
    - [R code GWASpoly Example for polyploid Species, optional]
    - [R code GWAS for categorical Traits]
    - [R code GWAS for categorical Traits - Examples]
    - [R code GWAS for longitudinal Traits]
    - [R code GWAS for multi-trait and multi-locus Models]

- Lecture 13 A Glimpse on ROH-based Alternative [Filippo, optional]
    - [ROH-based and Resampling Methods as alternative Approaches]
- Kahoot Quiz on what we learned about GWAS! [Filippo, Oscar, Christian]
- Conclusions and Wrap-Up Discussion on GWAS [Filippo, Oscar, Christian]

## Organization of the Code for the practical Sessions

1. preparatory_steps: download and prepare the data
2. preprocessing: filter the data
3. imputation: imputing missing genotypes
4. gwas: run the GWAS models
5. power_and_significance: designing GWAS experiments
6. steps: identifying the individual steps involved in a GWAS study
7. pipeline: assembling the individual steps into a bioinformatics pipeline for GWAS
8. collaborative exercise: trying out what we learnt on new data
