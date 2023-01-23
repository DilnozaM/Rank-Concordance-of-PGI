#!/bin/bash
#SBATCH -t 1:00:00
#SBATCH -p short

echo
echo "Script executed:"
date
echo

cd /lustre5/0/geighei/projects/CVD/3_METAL/INPUT

# map GC'ed height
	awk 'NR==FNR{array[$1]=$2"\t"$3;next} ($1 in array) { print array[$1], $0  } ' OFS="\t" \
	/lustre5/0/geighei/tools/easyqc/HRC.r1-1.GRCh37.wgs.mac5.sites.tab.rsid_map \
	GWAS_CAD_UKBnosibsrels_ldscGC1.tbl | \
	awk ' BEGIN {OFS="\t"; print "CHR","POS","rsID","EFFECT_ALLELE","OTHER_ALLELE","BETA","SE","PVAL","Direction","HetISq","HetChiSq","HetDf","HetPVal","N","EAF"} {$1=$1;print}' \
	> GWAS_CAD_UKBnosibsrels_ldscGC.txt




echo "Script finished at:"
date

