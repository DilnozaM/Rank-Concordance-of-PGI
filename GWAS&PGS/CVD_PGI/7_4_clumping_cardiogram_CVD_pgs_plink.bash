#!/bin/bash
#SBATCH -t 06:00:00
#SBATCH -N 1

#cartesius
#Clumping
#CVD
#Cardiogram

echo "Clump and Construct PGS"
echo "Script started"
date 

#change to the right directory
cd /path/projects/UKB_PGS_plink/CVD/CODE

#load plink - do we need to check for python here? 
module load 2019 
module load Python/3.6.6-foss-2018b 


# Identifying the columns to include into the construction of the plink score 
head /path/projects/UKB_LDpred/CVD/INPUT/CLEANED_cardiogram_CVD_sumstats.txt

#1cptid          2rsID           3CHR    4POS       5EFFECT_ALLELE   6OTHER_ALLELE    7EAF            8BETA           9SE             10PVAL          11Z                 12INFO
#10:100000625    rs7899632       10      100000625       A                G           0.549923        0.03424         0.0091953       0.0001964       3.72364142551086    0.9995
#10:100000645    rs61875309      10      100000645       A                C           0.818372        -0.019443       0.0121891       0.1106876       -1.59511366712883   0.99812
#10:100003242    rs12258651      10      100003242       T                G           0.875632        0.010175        0.0138099       0.4612484       0.73679027364427    0.98798
#10:100003304    rs72828461      10      100003304       A                G           0.970065        -0.033679       0.0317356       0.2885823       -1.06123722255133   0.732
#10:100003785    rs1359508       10      100003785       T                C           0.642467        -0.023418       0.0095299       0.013998        -2.45731854479061   0.999
#10:100004360    rs1048754       10      100004360       G                A           0.818554        -0.01972        0.0121924       0.1057913       -1.61740100390407   0.99896
#10:100004906    rs3750595       10      100004906       C                A           0.549972        0.034491        0.0091964       0.0001765       3.75048932190857    0.99997
#10:100004996    rs2025625       10      100004996       G                A           0.642604        -0.02366        0.009531        0.0130492       -2.48242576854475   0.999
#10:100005282    rs10786405      10      100005282       C                T           0.550158        0.034821        0.0091997       0.0001537       3.78501472874115    0.99946


#Clump the scores using the PRcise default thresholds 
/projects/0/geighei/tools/plink/plink \
      --bfile /path/data/UKB/bed/6_bed_merged_snp_qc_sqc_all/ukb_hm3_snp_sqc_consent_allchr \
      --clump /path/projects/UKB_LDpred/CVD/INPUT/CLEANED_cardiogram_CVD_sumstats.txt \
      --clump-p1 1 \
      --clump-kb 250 \
      --clump-r2 0.10 \
      --clump-p2 1 \
      --clump-snp-field rsID \
      --clump-field PVAL \
      --out /path/projects/UKB_PGS_plink/CVD/OUTPUT/cvd_clumped_cardiogram


#Now make a list of the clumped SNPs
head /path/projects/UKB_PGS_plink/CVD/OUTPUT/cvd_clumped_cardiogram.clumped


awk '{ print $3 }' /path/projects/UKB_PGS_plink/CVD/OUTPUT/cvd_clumped_cardiogram.clumped > /path/projects/UKB_PGS_plink/CVD/OUTPUT/cvd_list_clumped_SNPs_cardiogram.txt

#Remove the column name "SNP"
sed -i '1d' /path/projects/UKB_PGS_plink/CVD/OUTPUT/cvd_list_clumped_SNPs_cardiogram.txt

#count the number of SNPs included
grep -c rs  /path/projects/UKB_PGS_plink/CVD/OUTPUT/cvd_list_clumped_SNPs_cardiogram.txt
#112892 

#construct the pgs after removing the snps in the same region; 
#Need to choose for the score flag later: marker name (rsid), reference allele, weight (ld or gwas beta) (Source: Mills et al, 2020)
#using the ld_weight files since beta are already calculated there, otherwise use the same sumstats as in clumping 

head /path/projects/UKB_LDpred/CVD/INPUT/CLEANED_cardiogram_CVD_sumstats.txt

#1cptid          2rsID           3CHR    4POS       5EFFECT_ALLELE   6OTHER_ALLELE    7EAF            8BETA           9SE             10PVAL          11Z                 12INFO
#10:100000625    rs7899632       10      100000625       A                G           0.549923        0.03424         0.0091953       0.0001964       3.72364142551086    0.9995
#10:100000645    rs61875309      10      100000645       A                C           0.818372        -0.019443       0.0121891       0.1106876       -1.59511366712883   0.99812
#10:100003242    rs12258651      10      100003242       T                G           0.875632        0.010175        0.0138099       0.4612484       0.73679027364427    0.98798
#10:100003304    rs72828461      10      100003304       A                G           0.970065        -0.033679       0.0317356       0.2885823       -1.06123722255133   0.732
#10:100003785    rs1359508       10      100003785       T                C           0.642467        -0.023418       0.0095299       0.013998        -2.45731854479061   0.999
#10:100004360    rs1048754       10      100004360       G                A           0.818554        -0.01972        0.0121924       0.1057913       -1.61740100390407   0.99896
#10:100004906    rs3750595       10      100004906       C                A           0.549972        0.034491        0.0091964       0.0001765       3.75048932190857    0.99997
#10:100004996    rs2025625       10      100004996       G                A           0.642604        -0.02366        0.009531        0.0130492       -2.48242576854475   0.999
#10:100005282    rs10786405      10      100005282       C                T           0.550158        0.034821        0.0091997       0.0001537       3.78501472874115    0.99946


 
/projects/0/geighei/tools/plink/plink \
      --bfile /path/data/UKB/bed/6_bed_merged_snp_qc_sqc_all/ukb_hm3_snp_sqc_consent_allchr \
      --extract /path/projects/UKB_PGS_plink/CVD/OUTPUT/cvd_list_clumped_SNPs_cardiogram.txt \
      --score /path/projects/UKB_LDpred/CVD/INPUT/CLEANED_cardiogram_CVD_sumstats.txt header sum 2 5 8 \
      --out /path/projects/UKB_PGS_plink/CVD/OUTPUT/PGS_plink_cvd_cardiogram_clumped

echo "Script finished"
date 









