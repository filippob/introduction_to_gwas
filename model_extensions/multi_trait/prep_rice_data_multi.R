## run as: Rscript --vanilla prep_rice_multi.R plantgrainPhenotypes.txt rice_group.reference 'PH,PL'

library("data.table")
library("dplyr")

# -------------------------------------
# Reading File 1, and creating the subsets df and df.red
# -------------------------------------
## read from command line
args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
}


# Assign the arguments passed on from the bash script
#phenotype_file = "introduction_to_gwas/6.steps/data/plantgrainPhenotypes.txt"
#group_reference_file = "introduction_to_gwas/cross_reference/rice_group.reference"
#traits = 'SL,SW'

phenotype_file= args[1]
print(paste("phenotype file name:",phenotype_file))
group_reference_file= args[2]
print(paste("rice groups reference file:",group_reference_file))
traits= args[3]
print(paste("selected trait:",traits))

## read in files
phenotypes = fread(phenotype_file)
ref_group = fread(group_reference_file)
## select trait
target = unlist(strsplit(traits, ",")[[1]])

print(
  paste(
    "N. of matching records between phenotype and reference files:",
    sum(phenotypes$Accession %in% ref_group$id),
    sep=" ")
)

print("non-matching accessions:")
phenotypes$Accession[!(phenotypes$Accession %in% ref_group$id)]

## add population group to phenotype file
phenotypes$population = ref_group$population[match(phenotypes$Accession, ref_group$id)]

## rename column id (from Accession)
names(phenotypes)[1] <- "id"

## write out new phenotype file
writeLines(" - writing out the phenotype file")
temp = select(phenotypes, c(id,population,all_of(target)))
fwrite(x = temp, file = "rice_phenotypes_multi.txt", sep=" ")

print("DONE!")
