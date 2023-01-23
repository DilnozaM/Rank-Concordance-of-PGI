#!/bin/bash
#SBATCH -t 1:00:00
#SBATCH -p short

echo
echo "Script executed:"
date
echo

cd /projects/0/geighei/projects/EA_METAL/OUTPUT

/lustre5/0/geighei/tools/metal/generic-metal/metal << EOF

head /lustre5/0/geighei/projects/UKB_LDpred/EA_new/INPUT/CLEANED_UKB_EA_new_sans_sibs_plus_rels_fastgwa.txt

#1cptid          2rsID           3CHR    4POS        5EFFECT_ALLELE   6OTHER_ALLELE    7EAF            8MAC    9BETA           10SE            11PVAL          12Z                  13INFO          14N     15N_eff
#10:100000625    rs7899632       10      100000625       A             G               0.566952        337300  0.00886916      0.0112481       0.430401        0.78850294716441     0.999653        389419  389216
#10:100000645    rs61875309      10      100000645       A             C               0.794671        159900  -0.0137707      0.0138083       0.318632        -0.997277000065178   0.999278        389419  388610
#10:100001867    rs150203744     10      100001867       C             T               0.985988        10910   -0.0207         0.0497084       0.677097        -0.41642861166322   0.911954         389419  354161
#10:100002378    rs185724698     10      100002378       T             C               0.998336        1296    -0.0179284      0.145351        0.901834        -0.123345556618118   0.886747        389419  344481
#10:100002464    rs111551711     10      100002464       T             C               0.986509        10510   0.0479643       0.0506019       0.343193        0.94787547503157     0.913422        389419  354775
#10:100003242    rs12258651      10      100003242       T             G               0.884972        89590   0.0253099       0.0174796       0.147627        1.44796791688597     0.999416        389419  388719
#10:100003304    rs72828461      10      100003304       A             G               0.960381        30860   0.00634388      0.0286075       0.824504        0.221755833260509    0.997275        389419  388262
#10:100003516    rs185989018     10      100003516       G             A               0.993235        5269    -0.0100235      0.0706454       0.887171        -0.141884680389664   0.926364        389419  360532
#10:10000360     rs7919605       10      10000360        G             A               0.998052        1517    -0.0396874      0.140408        0.777439        -0.282657683322888   0.811555        389419  315432


##General parameters
SEPARATOR TAB
COLUMNCOUNTING LENIENT
MARKER rsID
ALLELE EFFECT_ALLELE OTHER_ALLELE
EFFECT BETA
STDERR SE
PVALUE PVAL
WEIGHT N
SCHEME STDERR
USESTRAND OFF
FREQLABEL EAF
##Start LDSC GC
GENOMICCONTROL 1.912
CUSTOMVARIABLE Weight
LABEL Weight as N
CUSTOMVARIABLE EAF
LABEL EAF as EAF
#CUSTOMVARIABLE CHR
#LABEL CHR AS CHR
#CUSTOMVARIABLE POS
#LABEL POS AS POS
# ^ doesn' work: rounds as if integers

##Specify cohort files as input
PROCESS /lustre5/0/geighei/projects/UKB_QC/OUTPUT/UKB/EA_new/CLEANED.ukb_ea_new_fastgwa_mlm_excl_sibs_sibrels_resid_qc.fastGWA.gz
OUTFILE GWAS_UKBnosibsrels_ea_new_ldscGC .tbl
ANALYZE




##Exit metal
QUIT

EOF

echo "Script finished at:"
date

