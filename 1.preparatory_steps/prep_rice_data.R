## run as: Rscript --vanilla retrieve_data.R plantgrainPhenotypes.txt rice_group.reference PH
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


## Assign the arguments passed on from the bash script
# phenotype_file = "plantgrainPhenotypes.txt"
# group_reference_file = "../introduction_to_gwas/cross_reference/rice_group.reference"
# trait = "PH"

phenotype_file= args[1]
print(paste("phenotype file name:",phenotype_file))
group_reference_file= args[2]
print(paste("rice groups reference file:",group_reference_file))
trait= args[3]
print(paste("selected trait:",trait))

## read in files
phenotypes = fread(phenotype_file)
ref_group = fread(group_reference_file)
## select trait
target = quote(trait)

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
fwrite(x = phenotypes[ , c("id", "population", eval(target)), with=FALSE],
       file = "rice_phenotypes.txt", sep=" ")

## write out ids file for Plink subset
phenotypes$fam <- rep("NF1", nrow(phenotypes))
fwrite(x = phenotypes[, c("fam","id")], file = "ids", sep="\t", col.names = FALSE)


## used in 2. pre-processing
ref_group$oldfam <- rep("NF1", nrow(ref_group))
ref_group$oldid <- ref_group$id
ref_group <- ref_group %>%
  select(oldfam, oldid, population, id)

fwrite(x = ref_group, file = "../2.pre-processing/update.ids", col.names = FALSE, sep = "\t")
