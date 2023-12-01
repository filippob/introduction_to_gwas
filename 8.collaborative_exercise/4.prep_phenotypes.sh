
#replace case-control code in pheno file
awk '{gsub("1","0",$3)}1' data/pheno > temp
awk '{gsub("2","1",$3)}1' temp > pigs_phenotypes.txt


