#!/bin/bash
#SBATCH -t 1:00:00
#SBATCH -p short

echo
echo "Script executed:"
date
echo

cd /projects/0/geighei/projects/EA_METAL/OUTPUT

/lustre5/0/geighei/tools/metal/generic-metal/metal << EOF


##General parameters
SEPARATOR TAB
COLUMNCOUNTING LENIENT
MARKER rsID
ALLELE EFFECT_ALLELE OTHER_ALLELE
EFFECT BETA
STDERR SE
PVALUE PVAL
WEIGHT N
SCHEME SAMPLESIZE
USESTRAND OFF
FREQLABEL EAF
AVERAGEFREQ ON
MINMAXFREQ ON
GENOMICCONTROL OFF

##Specify cohort files as input
PROCESS /lustre5/0/geighei/projects/EA_METAL/OUTPUT/GWAS_UKBnosibsrels_ea_new_ldscGC_chrpos.txt
PROCESS /lustre5/0/geighei/projects/23andme/1_QC/EA/OUTPUT/EA/CLEANED.education_years_5.1_allsnpinfo_allstat_noflips.dat

##Specify output file
OUTFILE GWAS_ea_new_meta_23andme_UKB_UKBnosibsrels .tbl


##Start Meta-analysis
ANALYZE HETEROGENEITY



##Exit metal
QUIT

EOF

echo "Script finished at:"
date

