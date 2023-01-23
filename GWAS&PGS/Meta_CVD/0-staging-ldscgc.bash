#!/bin/bash
#SBATCH -t 1:00:00
#SBATCH -p short

echo
echo "Script executed:"
date
echo

cd /lustre5/0/geighei/projects/CVD/3_METAL/INPUT
cp /lustre5/0/geighei/projects/CVD/1_QC/CARDIOGRAM/OUTPUT/CVD/CLEANED.cad.add.160614.website.gz .



### HEIGHT ###

/lustre5/0/geighei/tools/metal/generic-metal/metal << EOF


##General parameters
SEPARATOR TAB
COLUMNCOUNTING LENIENT
MARKER rsid
ALLELE EFFECT_ALLELE OTHER_ALLELE
EFFECT BETA
STDERR SE
PVALUE PVAL
WEIGHT N
SCHEME STDERR
USESTRAND OFF
FREQLABEL EAF
##Start LDSC GC
GENOMICCONTROL 1.0239
CUSTOMVARIABLE Weight
LABEL Weight as N
CUSTOMVARIABLE EAF
LABEL EAF as EAF

##Specify cohort files as input
PROCESS /lustre5/0/geighei/projects/UKB_QC/OUTPUT/UKB/CVD/CLEANED.ukb_CVD_fastgwa_mlm_excl_sibs_sibrels_resid.fastGWA.gz
OUTFILE GWAS_CAD_UKBnosibsrels_ldscGC .tbl
ANALYZE HETEROGENEITY
# ^ so that Z etc. is retained in output

##Exit metal
QUIT

EOF


##Exit metal
QUIT

EOF


echo "Script finished at:"
date

