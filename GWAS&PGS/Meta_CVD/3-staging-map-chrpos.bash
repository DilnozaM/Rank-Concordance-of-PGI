#!/bin/bash
#SBATCH -t 1:00:00
#SBATCH -p short

echo
echo "Script executed:"
date
echo

cd /lustre5/0/geighei/projects/CVD/3_METAL/OUTPUT

# Height
# MarkerName      Allele1 Allele2 Freq1   FreqSE  MinFreq MaxFreq Weight  Zscore  P-value Direction       HetISq  HetChiSq        HetDf   HetPVal
# N weighting with no custom vars
awk 'NR==FNR{array[$1]=$2"\t"$3;next} ($1 in array) { print array[$1], $0  } ' OFS="\t" \
/lustre5/0/geighei/tools/easyqc/HRC.r1-1.GRCh37.wgs.mac5.sites.tab.rsid_map \
GWAS_meta_CVD_CARDIOGRAM_UKBnosibsrels1.tbl | \
awk ' BEGIN {OFS="\t"; print "CHR","POS","rsid","EFFECT_ALLELE","OTHER_ALLELE","EAF","EAF_SE","MIN_EAF","MAX_EAF","N","Z",\
"P-value","Direction","HetISq","HetChiSq","HetDf","HetPVal"} {$1=$1;print}' \
> GWAS_meta_CVD_CARDIOGRAM_UKBnosibsrels.txt




echo "Script finished at:"
date

