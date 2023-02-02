#!/bin/bash
#SBATCH -t 06:00:00
#SBATCH -N 1

#cartesius
#Clumping
#CVD
#CARDIOGRAM

echo "Clump and Construct PGS"
echo "Script started"
date 

#change to the right directory
cd /path/projects/UKB_PGS_plink/CVD/CODE

#load plink - do we need to check for python here? 
module load 2019 
module load Python/3.6.6-foss-2018b 


# Identifying the columns to include into the construction of the plink score 
head /path/projects/UKB_LDpred/CVD/INPUT/CLEANED_ukb_CVD_fastgwa_mlm_excl_sibs_sibrels.txt

#1cptid          2rsID           3CHR    4POS       5EFFECT_ALLELE   6OTHER_ALLELE    7EAF            8MAC    9BETA           10SE            11PVAL          12Z                  13INFO          14N     15N_eff
#10:100000625    rs7899632       10      100000625       A                G           0.566892        340200  0.000755262     0.000587308     0.198453        1.28597260721802     0.999655        392771  393209
#10:100000645    rs61875309      10      100000645       A                C           0.794658        161300  -0.000332086    0.000720929     0.64506         -0.46063620689416    0.999276        392771  392653
#10:100001867    rs150203744     10      100001867       C                T           0.98599         11010   -0.0040897      0.0025952       0.115055        -1.57587083847102    0.912048        392771  357931
#10:100002378    rs185724698     10      100002378       T                C           0.998341        1303    -0.00716108     0.00760117      0.34614         -0.942102334245912   0.886751        392771  347989
#10:100002464    rs111551711     10      100002464       T                C           0.986511        10600   -0.00231217     0.0026424       0.381559        -0.875026491068725   0.913465        392771  358404
#10:100003242    rs12258651      10      100003242       T                G           0.884959        90370   0.00126802      0.000912665     0.164723        1.38935973221281     0.999416        392771  392693
#10:100003304    rs72828461      10      100003304       A                G           0.960388        31120   0.00191148      0.00149393      0.200723        1.27949770069548     0.99728         392771  392209
#10:100003516    rs185989018     10      100003516       G                A           0.993242        5309    0.0083527       0.00369098      0.0236357       2.26300332161106     0.926291        392771  364162
#10:10000360     rs7919605       10      10000360        G                A           0.998057        1526    0.0118321       0.00733971      0.106946        1.61206641679303     0.811936        392771  318761


#Clump the scores using the PRcise default thresholds 
/projects/0/geighei/tools/plink/plink \
      --bfile /path/data/UKB/bed/6_bed_merged_snp_qc_sqc_all/ukb_hm3_snp_sqc_consent_allchr \
      --clump /path/projects/UKB_LDpred/CVD/INPUT/CLEANED_ukb_CVD_fastgwa_mlm_excl_sibs_sibrels.txt \
      --clump-p1 1 \
      --clump-kb 250 \
      --clump-r2 0.10 \
      --clump-p2 1 \
      --clump-snp-field rsID \
      --clump-field PVAL \
      --out /path/projects/UKB_PGS_plink/CVD/OUTPUT/cvd_clumped_ukbnosibrels


#Now make a list of the clumped SNPs
head /path/projects/UKB_PGS_plink/CVD/OUTPUT/cvd_clumped_ukbnosibrels.clumped


awk '{ print $3 }' /path/projects/UKB_PGS_plink/CVD/OUTPUT/cvd_clumped_ukbnosibrels.clumped > /path/projects/UKB_PGS_plink/CVD/OUTPUT/cvd_list_clumped_SNPs_ukbnosibrels.txt

#Remove the column name "SNP"
sed -i '1d' /path/projects/UKB_PGS_plink/CVD/OUTPUT/cvd_list_clumped_SNPs_ukbnosibrels.txt

#count the number of SNPs included
grep -c rs /path/projects/UKB_PGS_plink/CVD/OUTPUT/cvd_list_clumped_SNPs_ukbnosibrels.txt
#112892 

#construct the pgs after removing the snps in the same region; 
#Need to choose for the score flag later: marker name (rsid), reference allele, weight (ld or gwas beta) (Source: Mills et al, 2020)
#using the ld_weight files since beta are already calculated there, otherwise use the same sumstats as in clumping 

head /path/projects/UKB_LDpred/CVD/INPUT/CLEANED_ukb_CVD_fastgwa_mlm_excl_sibs_sibrels.txt

#1cptid          2rsID           3CHR    4POS       5EFFECT_ALLELE   6OTHER_ALLELE    7EAF            8MAC    9BETA           10SE            11PVAL          12Z                  13INFO          14N     15N_eff
#10:100000625    rs7899632       10      100000625       A                G           0.566892        340200  0.000755262     0.000587308     0.198453        1.28597260721802     0.999655        392771  393209
#10:100000645    rs61875309      10      100000645       A                C           0.794658        161300  -0.000332086    0.000720929     0.64506         -0.46063620689416    0.999276        392771  392653
#10:100001867    rs150203744     10      100001867       C                T           0.98599         11010   -0.0040897      0.0025952       0.115055        -1.57587083847102    0.912048        392771  357931
#10:100002378    rs185724698     10      100002378       T                C           0.998341        1303    -0.00716108     0.00760117      0.34614         -0.942102334245912   0.886751        392771  347989
#10:100002464    rs111551711     10      100002464       T                C           0.986511        10600   -0.00231217     0.0026424       0.381559        -0.875026491068725   0.913465        392771  358404
#10:100003242    rs12258651      10      100003242       T                G           0.884959        90370   0.00126802      0.000912665     0.164723        1.38935973221281     0.999416        392771  392693
#10:100003304    rs72828461      10      100003304       A                G           0.960388        31120   0.00191148      0.00149393      0.200723        1.27949770069548     0.99728         392771  392209
#10:100003516    rs185989018     10      100003516       G                A           0.993242        5309    0.0083527       0.00369098      0.0236357       2.26300332161106     0.926291        392771  364162
#10:10000360     rs7919605       10      10000360        G                A           0.998057        1526    0.0118321       0.00733971      0.106946        1.61206641679303     0.811936        392771  318761

 
/projects/0/geighei/tools/plink/plink \
      --bfile /path/data/UKB/bed/6_bed_merged_snp_qc_sqc_all/ukb_hm3_snp_sqc_consent_allchr \
      --extract /path/projects/UKB_PGS_plink/CVD/OUTPUT/cvd_list_clumped_SNPs_ukbnosibrels.txt \
      --score /path/projects/UKB_LDpred/CVD/INPUT/CLEANED_ukb_CVD_fastgwa_mlm_excl_sibs_sibrels.txt header sum 2 5 9 \
      --out /path/projects/UKB_PGS_plink/CVD/OUTPUT/PGS_plink_CVD_UKB_clumped

echo "Script finished"
date 









