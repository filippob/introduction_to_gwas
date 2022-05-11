#!/bin/bash

## prepare data for GWAS

phenotypef=../../6.steps/data/plantgrainPhenotypes.txt
reff=../../cross_reference/rice_group.reference
traits='SL,SW'


## stand-alone script
Rscript --vanilla prep_rice_data_multi.R $phenotypef $reff $traits


