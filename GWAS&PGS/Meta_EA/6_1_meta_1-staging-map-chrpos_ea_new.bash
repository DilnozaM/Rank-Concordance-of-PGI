#!/bin/bash
#SBATCH -t 1:00:00
#SBATCH -p short

echo
echo "Script executed:"
date
echo

cd /projects/0/geighei/projects/EA_METAL/OUTPUT

awk 'NR==FNR{array[$1]=$2"\t"$3;next} ($1 in array) { print array[$1], $0  } ' OFS="\t" \
/lustre5/0/geighei/tools/easyqc/HRC.r1-1.GRCh37.wgs.mac5.sites.tab.rsid_map \
GWAS_UKBnosibsrels_ea_new_ldscGC1.tbl | \
awk ' BEGIN {OFS="\t"; print "CHR","POS","rsid","EFFECT_ALLELE","OTHER_ALLELE","BETA","SE","PVAL","Direction","N","EAF"} {$1=$1;print}' \
> GWAS_UKBnosibsrels_ea_new_ldscGC_chrpos.txt


echo "Script finished at:"
date

