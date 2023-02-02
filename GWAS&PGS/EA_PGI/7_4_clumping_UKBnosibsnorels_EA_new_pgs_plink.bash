#!/bin/bash
#SBATCH -t 06:00:00
#SBATCH -N 1

#cartesius
#Clumping
#EA

echo "Clump and Construct PGS"
echo "Script started"
echo "New EA"
date 

#change to the right directory
cd path/projects/UKB_PGS_plink/EA/Code

#load plink - do we need to check for python here? 
module load 2019 
module load Python/3.6.6-foss-2018b 


# Identifying the columns to include into the construction of the plink score 
head path/projects/UKB_LDpred/EA_new/INPUT/CLEANED_UKB_EA_new_sans_sibs_plus_rels_fastgwa.txt

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



#Clump the scores using the PRcise default thresholds 
/projects/0/geighei/tools/plink/plink \
      --bfile path/data/UKB/bed/6_bed_merged_snp_qc_sqc_all/ukb_hm3_snp_sqc_consent_allchr \
      --clump path/projects/UKB_LDpred/EA_new/INPUT/CLEANED_UKB_EA_new_sans_sibs_plus_rels_fastgwa.txt \
      --clump-p1 1 \
      --clump-kb 250 \
      --clump-r2 0.10 \
      --clump-p2 1 \
      --clump-snp-field rsID \
      --clump-field PVAL \
      --out path/projects/UKB_PGS_plink/EA/Output/EA_new_clumped_UKB_noukbsibrels


#Now make a list of the clumped SNPs
head path/projects/UKB_PGS_plink/EA/Output/EA_new_clumped_UKB_noukbsibrels.clumped


awk '{ print $3 }' path/projects/UKB_PGS_plink/EA/Output/EA_new_clumped_UKB_noukbsibrels.clumped > path/projects/UKB_PGS_plink/EA/Output/EA_new_list_clumped_SNPs_UKB_noukbsibrels.txt

#Remove the column name "SNP"
sed -i '1d' path/projects/UKB_PGS_plink/EA/Output/EA_new_list_clumped_SNPs_UKB_noukbsibrels.txt

#count the number of SNPs included
grep -c rs path/projects/UKB_PGS_plink/EA/Output/EA_new_list_clumped_SNPs_UKB_noukbsibrels.txt
#112892 
#Is this a normal thing? NB: the job was killed, see the log file in output folder

#construct the poly score after removing the snps in the same region; 
#Need to choose for the score flag later: marker name, reference allele, weight (ld or gwas beta) (Source: Mills et al, 2020)
#using the ld_weight files since beta are already calculated there, otherwise use the same sumstats as in clumping 

head path/projects/UKB_LDpred/EA_new/INPUT/CLEANED_UKB_EA_new_sans_sibs_plus_rels_fastgwa.txt

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

/projects/0/geighei/tools/plink/plink \
      --bfile path/data/UKB/bed/6_bed_merged_snp_qc_sqc_all/ukb_hm3_snp_sqc_consent_allchr \
      --extract path/projects/UKB_PGS_plink/EA/Output/EA_new_list_clumped_SNPs_UKB_noukbsibrels.txt \
      --score path/projects/UKB_LDpred/EA_new/INPUT/CLEANED_UKB_EA_new_sans_sibs_plus_rels_fastgwa.txt header sum 2 5 9 \
      --out path/projects/UKB_PGS_plink/EA/Output/PGS_plink_EA_new_ukb_nosibssibrels_clumped

echo "Script finished"
date 









