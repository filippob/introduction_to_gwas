## activate the conda env with snakemake
conda activate snakemake #(or whichever env name is used: 2025 --> gwas)

## visualize the help manual for snakemake
snakemake --help

## input data (unsorted snp file)
less snp.map

## dry runs for the first example_pipeline (long and short options) 
snakemake --dryrun --snakefile example_snakefile
snakemake -n -s example_snakefile

## dry run to produce a DAG of the pipeline
man dot ## from the graphviz package (apt install graphviz)
snakemake --dag --dryrun --snakefile example_snakefile | dot -Tsvg > dag_example.svg

## actual run of the first example pipeline
snakemake --cores 1 --snakefile example_snakefile

## output data
zless snp_sorted.map.gz

## unzip sorted snp file
gunzip snp_sorted.map.gz

## rerun the first example pipeline: dry run for DAG
snakemake --dag --dryrun --snakefile example_snakefile | dot -Tsvg > dag_example_unzipped.svg

## rerun the first example pipeline: actual run for DAG
snakemake --cores 1 --snakefile example_snakefile

## run the second example pipeline: dry run for DAG
snakemake --dag -n --snakefile example_snakefile_2 | dot -Tsvg > dag_example_2.svg

## run the second example pipeline: actual run
snakemake --cores 1 --snakefile example_snakefile_2

