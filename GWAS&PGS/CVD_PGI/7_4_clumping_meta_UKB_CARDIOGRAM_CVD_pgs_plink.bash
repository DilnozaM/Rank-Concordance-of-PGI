#!/bin/bash
#SBATCH -t 06:00:00
#SBATCH -N 1

#cartesius
#Clumping
#CVD
#Cardiogram + UKB Meta

echo "Clump and Construct PGS"
echo "Script started"
date 

#change to the right directory
cd /path/projects/UKB_PGS_plink/CVD/CODE

#load plink 
module load 2019 
module load Python/3.6.6-foss-2018b 


# Identifying the columns to include into the construction of the plink score 
head /path/projects/UKB_LDpred/CVD/INPUT/GWAS_meta_CVD_CARDIOGRAM_UKBnosibsrels.txt

#1CHR    2POS            3rsid      4EFFECT_ALLELE   5OTHER_ALLELE    6EAF    7EAF_SE 8MIN_EAF 9MAX_EAF 10N             11Z     12P-value 13Direction     14HetISq  15HetChiSq      16HetDf 17HetPVal
#6       130840091       rs2326918       a                g           0.8457  0.0011  0.8433   0.8462   474257.00       0.103   0.918     -+              14.2      1.166           1       0.2802
#3       104998275       rs112634005     a                c           0.9948  0.0000  0.9948   0.9948   392771.00       2.452   0.01422   +?              0.0       0.000           0       1
#13      33786576        rs151222586     a                g           0.9965  0.0000  0.9965   0.9965   392771.00       1.109   0.2673    +?              0.0       0.000           0       1
#20      8411670         rs6039163       t                c           0.9983  0.0000  0.9983   0.9983   392771.00       -0.421  0.6741    -?              0.0       0.000           0       1
#3       176666749       rs66941928      t                c           0.8006  0.0049  0.7898   0.8028   474257.00       0.294   0.7689    +-              42.9      1.751           1       0.1857
#7       34606102        rs146253013     t                c           0.9956  0.0000  0.9956   0.9956   392771.00       -1.717  0.08594   -?              0.0       0.000           0       1
#16      8600861         rs7190157       a                c           0.6099  0.0936  0.4043   0.6525   474257.00       -1.251  0.2108    -+              0.0       0.337           1       0.5617
#11      100009976       rs12364336      a                g           0.8700  0.0034  0.8685   0.8774   474257.00       -0.649  0.5165    --              0.0       0.459           1       0.4979
#7       145771806       rs6977693       t                c           0.8588  0.0082  0.8551   0.8769   474257.00       0.889   0.3739    +-              68.4      3.166           1       0.07517


#Clump the scores using the PRcise default thresholds 
/projects/0/geighei/tools/plink/plink \
      --bfile /path/data/UKB/bed/6_bed_merged_snp_qc_sqc_all/ukb_hm3_snp_sqc_consent_allchr \
      --clump /path/projects/UKB_LDpred/CVD/INPUT/GWAS_meta_CVD_CARDIOGRAM_UKBnosibsrels.txt \
      --clump-p1 1 \
      --clump-kb 250 \
      --clump-r2 0.10 \
      --clump-p2 1 \
      --clump-snp-field rsid \
      --clump-field P-value \
      --out /path/projects/UKB_PGS_plink/CVD/OUTPUT/cvd_clumped_meta_ukb_cardiogram


#Now make a list of the clumped SNPs
head /path/projects/UKB_PGS_plink/CVD/OUTPUT/cvd_clumped_meta_ukb_cardiogram.clumped


awk '{ print $3 }' /path/projects/UKB_PGS_plink/CVD/OUTPUT/cvd_clumped_meta_ukb_cardiogram.clumped > /path/projects/UKB_PGS_plink/CVD/OUTPUT/cvd_list_clumped_SNPs_meta_ukb_cardiogram.txt

#Remove the column name "SNP"
sed -i '1d' /path/projects/UKB_PGS_plink/CVD/OUTPUT/cvd_list_clumped_SNPs_meta_ukb_cardiogram.txt

#count the number of SNPs included
grep -c rs  /path/projects/UKB_PGS_plink/CVD/OUTPUT/cvd_list_clumped_SNPs_meta_ukb_cardiogram.txt
#112892 

#construct the pgs after removing the snps in the same region; 
#Need to choose for the score flag later: marker name (rsid), reference allele, weight (ld or gwas beta) (Source: Mills et al, 2020)
#using the ld_weight files since beta are already calculated there, otherwise use the same sumstats as in clumping 


head /path/projects/UKB_LDpred/CVD/INPUT/LD_pred_w_meta_CVD_CARDIOGRAM_UKBnosibsrels_LDpred_p1.0000e+00.txt

#1chrom     2pos      3sid         4nt1 5nt2  6raw_beta      7ldpred_beta
#chrom_1    754182    rs3131969    A    G    -2.0072e-04    -5.9824e-06
#chrom_1    761732    rs2286139    C    T    -5.1730e-04    -1.5307e-05
#chrom_1    779322    rs4040617    G    A    -1.9196e-04    -6.0128e-06
#chrom_1    785989    rs2980300    T    C    -9.3853e-05    -2.8271e-06
#chrom_1    838555    rs4970383    A    C    -9.4135e-04    -2.2371e-05
#chrom_1    846808    rs4475691    T    C    -1.4097e-03    -3.5742e-05
#chrom_1    853954    rs1806509    C    A    -7.6012e-04    -1.5524e-05
#chrom_1    854250    rs7537756    G    A    -1.6130e-03    -4.0024e-05
#chrom_1    873558    rs1110052    G    T    -2.3635e-03    -5.3769e-05
 
/projects/0/geighei/tools/plink/plink \
      --bfile /path/data/UKB/bed/6_bed_merged_snp_qc_sqc_all/ukb_hm3_snp_sqc_consent_allchr \
      --extract /path/projects/UKB_PGS_plink/CVD/OUTPUT/cvd_list_clumped_SNPs_meta_ukb_cardiogram.txt \
      --score /path/projects/UKB_LDpred/CVD/INPUT/LD_pred_w_meta_CVD_CARDIOGRAM_UKBnosibsrels_LDpred_p1.0000e+00.txt header sum 3 4 6 \
      --out /path/projects/UKB_PGS_plink/CVD/OUTPUT/PGS_plink_cvd_meta_ukb_cardiogram_clumped

echo "Script finished"
date 









