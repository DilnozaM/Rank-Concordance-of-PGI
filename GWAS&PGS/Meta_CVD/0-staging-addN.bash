#!/bin/bash
#SBATCH -t 1:00:00
#SBATCH -p short

echo
echo "Script executed:"
date
echo

cd /lustre5/0/geighei/projects/CVD/3_METAL/INPUT
cp /lustre5/0/geighei/projects/CVD/1_QC/CARDIOGRAM/OUTPUT/CVD/CLEANED.cad.add.160614.website.gz .

gunzip CLEANED.cad.add.160614.website.gz
awk ' NR > 1 { print $0, 81486 } ' CLEANED.cad.add.160614.website | \
awk ' BEGIN { OFS="\t"; print "cptid","rsID","CHR","POS","EFFECT_ALLELE","OTHER_ALLELE","EAF","BETA","SE","PVAL","Z","INFO","Neffmax" } { $1=$1; print }' OFS="\t" \
> CLEANED.cad.add.160614.website.N.txt
gzip  CLEANED.cad.add.160614.website.N.txt


echo "Script finished at:"
date

