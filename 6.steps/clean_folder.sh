#!/bin/bash
rm -rf *.log *.map *.ped *.log *.vcf *.raw *.nosex *.kinship *.irem *.pdf *.results *.png *.vcf.gz *.results.gz

if [ -d "data" ] 
then
	rm -r data/
fi
