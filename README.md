# introduction_to_gwas

**Material for the course "Introduction to genome-wide association studies (GWAS)"**

Instructors: *Filippo Biscarini, Oscar Gonzalez-Recio, Christian Werner*

This course will introduce students, researchers and professionals to the steps needed to build an analysis pipeline for Genome-Wide Association Studies (GWAS). The course will describe all the necessary steps involved in a typical GWAS study, which will then be used to build a reusable and reproducible bioinformatics pipeline.

Each day the course will start at **14:00** and end at **20:00** (CET).
As a general rule, we'll have a longer break (30 minutes) at 16:00 and two shorter breaks (10-15 minutes) later on during the day (to be decided flexibly depending on the sessions). 

<!-- timetable: [here](https://docs.google.com/spreadsheets/d/1Cy8vBD6I_no8UPzYPU9bz7ASWyI3bc4Y9vcdr5S1TBw/edit#gid=0) -->

**day 1**

- Lecture 0	General Introduction / Overview of the course [Filippo, Oscar, Christian]
    - [slides 0.General Introduction](slides/1.General_Introduction.pdf)
- Lecture 1	GWAS overview: case studies / examples from literature [Oscar]
    - [slides 1.Overview](slides/Lecture1.pdf)
- Lecture 2	Introduction to GWAS: Linkage disequilibrium and Linear Regression [Oscar]
    - [slides 2.Intro to GWAS](slides/Lecture2.pdf)
- Lab 1 - Practicalities and set-up (server, github repo, conda envs, etc) and description of datasets [Christian]
    - [slides 3.Description of datasets](slides/Description_of_datasets.pdf)
- Lab 2 - part 1 basic Linux and advanced R libraries [Christian]
    - [slides 4.Linux and the Shell](slides/4.Linux_and_the_Shell.pdf)
- Lab 2 - part 2 basic Linux and advanced R libraries [Christian]
    - [Linux cheatsheet](slides/Linux_cheatsheet.pdf)
    - [Introduction to the tidyverse](slides/Tidyverse_Intro.html)
- Lab 3 (demonstration) GWAS: basic models (linear and logistic regression) [Oscar]
    - [R code. Exercise on simple linear regression](basic_model/1.Basis_of_linear_regression.R) 
    - [Rmarkdown code. Exercise on simple logistic regression](basic_model/2.exercise.Basis_of_logistic_regression.Rmd)


**day 2**

- Lecture 4 EDA theory [Christian]
    - [slides 5.1 Data Pre-Processing & EDA](slides/Data_Pre-Processing_&_EDA.pdf)
- Lab 4 EDA practice [Christian]
- Lecture 5 data preprocessing: theory [Christian]
    - [slides 5.2 Data Types & Formats](slides/Data_Types_&_Formats.pdf)
- Lab 5 data preprocessing: practice [Christian]
- Lecture 6 The multiple testing issue [Oscar]
    - [slides 6. Multiple_testing](slides/Lecture6.pdf)
- Lecture 7 GWAS: experimental design and statistical power [Oscar]
    - [slides 7. Design and power](slides/Lecture7.pdf)
    - [R code. Exercise on statistical power](5.power_and_significance/StatisticalPower_exercise.R)
- Lecture 8	Imputation of missing genotypes: theory [Christian]


**day 3**

- Lab 6 - part 1 practical session on imputation (Beagle) [Christian]
- Lecture 9: KNN Imputation 
    - [slides 7.2 KNN Imputation]
- Lab 7 (demonstration) KNNI imputation [Filippo]
    - [R code. knni.Rmd](3.imputation/knni.Rmd)
- Lab 8 GWAS: the stand-alone script(s) for the full model [Filippo]
- Lab 9 revising the steps involved in GWAS [Filippo]
    - [slides 9. Revising the steps]  
- Lecture 10 Bioinformatics pipelines: a super-elementary introduction [Filippo]
    - [slides 10. A bioinformatics pipeline for GWAS]
- Lab 10 Building a pipeline with Snakemake [Filippo]

**day 4**

- Lab 11 The GWAS pipeline for continuous phenotype [Filippo]
- Lab 12 The GWAS pipeline for binary phenotype [Filippo]
- Lab 13 Introducing the exercise (+ light touch on RMarkdown) [Filippo]
- Collaborative exercise: Let's build our own GWAS pipeline on new data [Filippo, Oscar, Christian]
    - part 1: individual/group break-out sessions to give it a try independetly
    - part 2: whole-group revision of the exercise
- Discussion Q&A on building pipelines for GWAS [Filippo, Oscar, Christian]
- Lecture 11 (part 1) GWAS model extensions: a primer on categorical traits and longitudinal data [Filippo]
 
**day 5**

- Lecture 11 (part 2) GWAS model extensions: a primer on categorical traits and longitudinal data [Filippo]
    - - [slides 11.GWAS model extensions]
- Lecture 12 A light touch on post-GWAS analysis. Inferring functionality [Oscar]
    - [R code. Exercise on R, and FUMA](functional_analysis/getGenesFromSNP.R)
- Lecture 13 A glimpse on ROH-based alternative [Filippo, optional]
- Kahoot quiz on what we learned about GWAS! [Filippo, Oscar, Christian]
- Wrap-up discussion on GWAS [Filippo, Oscar, Christian]

## organization of the code for the practical sessions

1. preparatory_steps: download and prepare the data
2. preprocessing: filter the data
3. imputation: imputing missing genotypes
4. gwas: run the GWAS models
5. power_and_significance: designing GWAS experiments
6. steps: identifying the individual steps involved in a GWAS study
7. pipeline: assembling the individual steps into a bioinformatics pipeline for GWAS
8. collaborative exercise: trying out what we learnt on new data
