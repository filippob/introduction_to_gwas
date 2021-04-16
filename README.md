# introduction_to_gwas

**Material for the course "Introduction to genome-wide association studies (GWAS)"**

Instructors: *Filippo Biscarini, Oscar Gonzalez-Recio, Christian Werner*

This course will introduce students, researchers and professionals to the steps needed to build an analysis pipeline for Genome-Wide Association Studies (GWAS). The course will describe all the necessary steps involved in a typical GWAS study, which will then be used to build a reusable and reproducible bioinformatics pipeline.

timetable: [here](https://docs.google.com/spreadsheets/d/1Cy8vBD6I_no8UPzYPU9bz7ASWyI3bc4Y9vcdr5S1TBw/edit#gid=0)

**day 1**

- Lecture 0	General Introduction / Overview of the course [Filippo, Oscar, Christian]
    -   [slides 1.General Introduction (draft)](1. \[CHECK\] General Introduction.pdf) (Filippo, Oscar, Christian)
- Lecture 1	Introduction to GWAS: Linkage disequilibrium and Linear Regression [Oscar]
- Lecture 2	GWAS: case studies / examples from literature [Oscar]
- Lab 1 - Practicalities and set-up (server, github repo, conda envs, etc) and description of datasets [Christian]
- Lab 2 - part 1   basic Linux and R [Christian]
- Lab 2 - part 2	basic Linux and R [Christian]
- Lab 3	GWAS: basic models [Oscar]
- Lab 3 (demonstration)    GWAS: basic models (linear and logistic regression, population structure, etc.) [Oscar]

**day 2**

- Lecture 4 EDA: theory
- Lab 4    EDA practice
- Lecture 5	data preprocessing: theory
- Lab 5   data preprocessing: practice
- Lecture 6	Imputation of missing genotypes: theory
- Lab 6 - part 1    practical session on imputation (Beagle)
- Lecture 8 GWAS: experimental design and statistical power

**day 3**

- Lab 7 (demonstration) KNNI imputation [Filippo]
- Lecture 7 GWAS, the full model (all SNPs)
- Lab 9 (demonstration)  a few steps in the past (GenABEL)
- Lab 10   GWAS: the stand-alone script(s) for the full model
- Lecture 9 The multiple testing issue?
- Lab 10  revising the steps involved in GWAS [Filippo]

**day 4**

- Lecture 10   Bioinformatics pipelines: a super-elementary introduction [Filippo]
- Lab 11    Building a pipeline with Snakemake [Filippo]
- Lab 12   The GWAS pipeline for continuous phenotype [Filippo]
- Lab 13   The GWAS pipeline for binary phenotype [Filippo]
- Lab 14  Introducing the exercise (+ light touch on RMarkdown) [Filippo]
- Collaborative exercise Let's build our own GWAS pipeline on new data [Filippo]
- Discussion Q&A on building pipelines for GWAS

**day 5**

- Lecture 11 GWAS models for categorical traits (a primer) 
- Lecture 12 GWAS models for longitudinal data (a primer)
- Lecture 13   A light touch on post-GWAS analysis
- Lecture 14	A glimpse on ROH-based alternative [Filippo]
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
