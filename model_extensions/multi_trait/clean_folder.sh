#!/bin/bash
rm -rf *.log *.map *.ped *.log *.vcf *.raw *.nosex *.kinship *.irem *.pdf *.results *.png *.results *.bim *.bed *.fam *.txt

if [ -d "data" ] 
then
	rm -r data/
fi
