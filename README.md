# introduction_to_gwas

**Material for the Course "Introduction to genome-wide association studies (GWAS)"**

Instructors: *Filippo Biscarini, Oscar Gonzalez-Recio, Christian Werner*

This course will introduce students, researchers and professionals to the steps needed to build an analysis pipeline for Genome-Wide Association Studies (GWAS). The course will describe all the necessary steps involved in a typical GWAS study, which will then be used to build a reusable and reproducible bioinformatics pipeline.

Each day the course will start at **14:00** and end at **20:00** (CET).
As a general rule, we'll have a longer break (30 minutes) at 16:00 and two shorter breaks (10-15 minutes) later on during the day (to be decided flexibly depending on the sessions).  

<!-- timetable: [here](https://docs.google.com/spreadsheets/d/1Cy8vBD6I_no8UPzYPU9bz7ASWyI3bc4Y9vcdr5S1TBw/edit#gid=0) -->

**Day 1**

- Lecture 0	General Introduction / Overview of the Course [Filippo, Oscar, Christian]
    - [General Introduction](slides/0_General_introduction.pdf)
    - [GWAS Workflow (short)](slides/GWAS_workflow_short.pdf)
- Lecture 1	GWAS Overview: Case Studies / Examples from Literature [Oscar]
    - [GWAS Overview](slides/1_GWAS_overview.pdf)
- Lecture 2	Introduction to GWAS: Linkage Disequilibrium and Linear Regression [Oscar]
    - [Introduction to GWAS](slides/2_Introduction_to_GWAS.pdf)
- Lab 1 - Practicalities and Set-up (Server, github repo, R, etc) and Description of Datasets [Christian]
    - [Description of Datasets](slides/Description_of_datasets.pdf)
 - [Course Manual](slides/gwas_manual.pdf)
 - [GWAS Workflow](slides/GWAS_workflow.pdf)


**Day 2**

- Lab 2 (Demonstration) GWAS: Basic Models (Linear and Logistic Regression) [Oscar]
    - [R code. Exercise on Simple Linear Regression]<!--(basic_model/1.Basis_of_linear_regression.R)
    - [Rmarkdown Code. Exercise on Simple Logistic Regression]<!--(basic_model/2.exercise.Basis_of_logistic_regression.Rmd)
- Lecture 3 The Multiple Testing Issue [Oscar]
    - [Multiple Testing]<!--(slides/6_Multiple_testing.pdf)-->
    - [R code. Exercise on multiple testing correction]<!--(5.power_and_significance/MultipleTestingCorrection.R)-->
- Lecture 4 Statistical Power, Population Stratification and Experimental Design [Oscar] 
    - [Statistical Power and Population Stratification]<!--(slides/7_Experimental_design.pdf)-->
    - [R code. Exercise on statistical power]<!--(5.power_and_significance/StatisticalPower_exercise.R)
- Lecture 5 Initial Data Analysis, Exploratory Data Analysis and Data Pre-Processing [Christian]
    - [IDA, EDA & Data Pre-Processing]<!--(slides/5_Data_pre-processing.pdf)-->
- Lab 3 GWAS: a first simple exercise for you! [Christian, Filippo]
    - [TBD]<!--()-->

**Day 3**

- Lab 4 Data filtering and mean/median imputation in R [Filippo]
    - [filter_genotype_data.R]<!--(0.r_scripts/filter_genotype_data.R)-->
    - [mean_imputation.R]<!--(0.r_scripts/mean_imputation.R)-->
    - [median_imputation.R]<!--(0.r_scripts/median_imputation.R)-->
- Lab 5 GWAS: The Stand-Alone Script(s) for the Full Model [Filippo]
    - [gwas_rrblup.R]<!--(4.gwas/gwas_rrblup.R)-->
    - [gwas_statgengwas.R]<!--(4.gwas/gwas_statgengwas.R)-->
    - [gwas_sommer.R]<!--(4.gwas/gwas_sommer.R)-->
- Lecture 6 KNN Imputation 
    - [KNN Imputation]<!--(slides/9_KNN_imputation.pdf)-->
- Lab 6 (Demonstration) KNNI Imputation [Filippo]
    - [knni_illustration.Rmd]<!--(3.imputation/knni_illustration.Rmd)-->
    - [data_for_KNNI_illustration]<!--(model_extensions_data/GenRiz44.txt)-->
    - [knni_tidymodels.R]<!--(3.imputation/knni_tidymodels.R)-->
    - [02_knni.sh]<!--(3.imputation/02_knni.sh)--> [support script]
    - [hamming.R]<!--(3.imputation/hamming.R)--> [support script]
    - [knni.R]<!--(3.imputation/knni.R)--> [support script]
- Lecture 7 Data Types & Formats
    - [Common Data Types and Formats]<!--(slides/4_Data_types.pdf)-->
- Lab 7 EDA & IDA and preprocessing with Plink [Christian]
    - [Linux and the Shell]<!--(slides/3_Linux_intro.pdf)-->
    - [Unix Cheatsheet]<!--(slides/Unix_cheatsheet.pdf)-->
- Lecture 8	Imputation of Missing Genotypes [Christian]
    - [Imputation]<!--(slides/8_Imputation.pdf)-->
- Lab 8 Imputation of Missing Genotypes using Beagle [Christian]


**Day 4**
- Lecture 9 Brief Intermission:
    - [R code PCA & Population Structure]<!--(4.gwas/PCA_screeplots.R)-->
    - [Imputed rice genotypes]<!--(4.gwas/rice_imputed.raw)-->
- Lab 9 Revising the Steps involved in GWAS [Filippo]
    - [slides]<!--(slides/10.1_Revising_the_steps.pdf)-->
    - [1.get_data.sh]<!--(6.steps/1.get_data.sh)-->
    - [2.step_filtering.sh]<!--(6.steps/2.step_filtering.sh)-->
    - [3.step_imputation.sh]<!--(6.steps/3.step_imputation.sh)-->
    - [4.gwas.sh]<!--(6.steps/4.gwas.sh)-->
- Lab 10 Introducing the Exercise [Filippo]
    - [Collaborative Exercise]<!--(slides/10.2_Collaborative_exercise.pdf)-->
- Collaborative Exercise: let's build our own GWAS workflow on new data [Filippo, Oscar, Christian]
    - Part 1: Individual/Group Break-Out Sessions to give it a try independetly
    - Part 2: Whole-Group Revision of the Exercise
- Lecture 10 Bioinformatics Pipelines: a super-elementary Introduction [Filippo]
    - [A bioinformatics pipeline for GWAS]<!--(slides/11_A_bioinformatic_pipeline_for_GWAS.pdf)-->
- Lab 11 Building a Pipeline with Snakemake [Filippo]
- Lab 12 The GWAS pipeline for Continuous Phenotypes [Filippo]
    - Plug-In for Mean or KNN Imputation
    - The GWAS pipeline for Binary Phenotypes (Guided Exercise) [Filippo]
    
**Day 5**

- Lecture 11 A light Touch on Post-GWAS Analysis: Inferring Functionality [Oscar]
    - [slides]<!--(slides/Functional_Analysis.pdf)-->
    - [R code. Exercise on R, and FUMA]<!--(functional_analysis/getGenesFromSNP.R)-->
- Lecture 12 GWAS Model Extensions: [Filippo]
    - [12.1 GWAS Model Extensions_Dominance_and_other_genotype_Codifications]<!--(slides/12.1.GWAS_model_extensions_genotype_codification.pdf)-->
    - [12.2 GWAS Model Extensions_Polyploids]<!--(slides/12_2_GWAS_model_extensions_polyploids.pdf)-->
    - [12.3 GWAS Model Extensions_Trait_Types]<!--(slides/13.3_GWAS_model_extensions_trait_type.pdf)-->
    - [12.4 GWAS Model Extensions_Multi-Trait-Locus, software]<!--(slides/13.4.GWAS_model_extensions_multi_trait_and_locus.pdf)-->
    - [R code GWASpoly (vignette)]<!--(slides/GWASpoly_vignette.pdf)-->
    - [R code GWAS for categorical Traits]<!--(model_extensions/1.categorical_gwas.Rmd)-->
    - [R code GWAS for categorical Traits - Examples]<!--(model_extensions/2.categorical_gwas_example.Rmd)-->
    - [R code GWAS for longitudinal Traits]<!--(model_extensions/3.longitudinal_gwas.Rmd)-->
    - [R code GWAS for multi-trait and multi-locus Models]

<!-- - Lecture 13 A Glimpse on ROH-based Alternative [Filippo, optional]
    - [ROH-based and Resampling Methods as alternative Approaches]
    - [Other gene actions](slides/13.1.GWAS_model_extensions_genotype_codification.pdf)-->
- Final Quiz on what we learned about GWAS! [Filippo, Oscar, Christian]
- Conclusions and Wrap-Up Discussion on GWAS [Filippo, Oscar, Christian]

## Organization of the Code for the practical Sessions

0. the GWAS workflow in R
1. preparatory_steps: download and prepare the data
2. preprocessing: filter the data
3. imputation: imputing missing genotypes
4. gwas: run the GWAS models
5. power_and_significance: designing GWAS experiments
6. steps: identifying the individual steps involved in a GWAS study
7. pipeline: assembling the individual steps into a bioinformatics pipeline for GWAS
8. collaborative exercise: trying out what we learnt on new data
