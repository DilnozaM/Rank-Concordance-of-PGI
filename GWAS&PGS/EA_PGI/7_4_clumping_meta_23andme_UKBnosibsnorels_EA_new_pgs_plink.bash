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
head path/projects/EA_METAL/OUTPUT/GWAS_ea_new_meta_23andme_UKB_UKBnosibsrels.txt

#1CHR    2POS            3rsid       4EFFECT_ALLELE   5OTHER_ALLELE    6EAF    7EAF_SE 8MIN_EAF   9MAX_EAF 10N             11Z     12P-value 13Direction     14HetISq  15HetChiSq    16HetDf 17HetPVal
#6       130840091       rs2326918       a                 g           0.8446  0.0016  0.8429     0.8462   754955.00       0.171   0.8641    +-                0.0       0.512         1       0.4744
#3       104998275       rs112634005     a                 c           0.9948  0.0000  0.9948     0.9948   389419.00       -0.366  0.7141    -?                0.0       0.000         0       1
#13      33786576        rs151222586     a                 g           0.9965  0.0000  0.9965     0.9965   389419.00       0.516   0.606     +?                0.0       0.000         0       1
#20      8411670         rs6039163       t                 c           0.5168  0.4969  0.0039     0.9983   754955.00       0.385   0.7003    +-                0.0       0.258         1       0.6115
#3       176666749       rs66941928      t                 c           0.7998  0.0033  0.7964     0.8029   754955.00       -0.850  0.3956    -+                0.0       0.730         1       0.393
#7       34606102        rs146253013     t                 c           0.5161  0.4949  0.0052     0.9956   754955.00       1.258   0.2082    ++                0.0       0.398         1       0.5282
#16      8600861         rs7190157       a                 c           0.5172  0.1397  0.3730     0.6525   754955.00       1.066   0.2865    ++                0.0       0.703         1       0.4018
#11      100009976       rs12364336      a                 g           0.8681  0.0004  0.8676     0.8685   754955.00       0.861   0.3893    ++                0.0       0.000         1       0.9851
#7       145771806       rs6977693       t                 c           0.8524  0.0028  0.8496     0.8551   754955.00       -0.707  0.4796    --                0.0       0.501         1       0.4791


#Clump the scores using the PRcise default thresholds 
/projects/0/geighei/tools/plink/plink \
      --bfile path/data/UKB/bed/6_bed_merged_snp_qc_sqc_all/ukb_hm3_snp_sqc_consent_allchr \
      --clump path/projects/EA_METAL/OUTPUT/GWAS_ea_new_meta_23andme_UKB_UKBnosibsrels.txt \
      --clump-p1 1 \
      --clump-kb 250 \
      --clump-r2 0.10 \
      --clump-p2 1 \
      --clump-snp-field rsid \
      --clump-field P-value \
      --out path/projects/UKB_PGS_plink/EA/Output/EA_new_clumped_meta_23andme_UKB_noukbsibrels


#Now make a list of the clumped SNPs
head path/projects/UKB_PGS_plink/EA/Output/EA_new_clumped_meta_23andme_UKB_noukbsibrels.clumped


awk '{ print $3 }' path/projects/UKB_PGS_plink/EA/Output/EA_new_clumped_meta_23andme_UKB_noukbsibrels.clumped > path/projects/UKB_PGS_plink/EA/Output/EA_new_list_clumped_SNPs_meta_23andme_UKB_noukbsibrels.txt

#Remove the column name "SNP"
sed -i '1d' path/projects/UKB_PGS_plink/EA/Output/EA_new_list_clumped_SNPs_meta_23andme_UKB_noukbsibrels.txt

#count the number of SNPs included
grep -c rs path/projects/UKB_PGS_plink/EA/Output/EA_new_list_clumped_SNPs_meta_23andme_UKB_noukbsibrels.txt
#112892 
#Is this a normal thing? NB: the job was killed, see the log file in output folder

#construct the poly score after removing the snps in the same region; 
#Need to choose for the score flag later: marker name, reference allele, weight (ld or gwas beta) (Source: Mills et al, 2020)
#using the ld_weight files since beta are already calculated there, otherwise use the same sumstats as in clumping 

head path/projects/UKB_LDpred/EA_new/INPUT/LD_pred_w_EA_new_meta_23andme_UKB_nosibrels_LDpred_p1.0000e+00.txt

#1chrom     2pos      3sid        4nt1  5nt2 6raw_beta      7ldpred_beta
#chrom_1    754182    rs3131969    A    G    -5.8622e-04    -8.2926e-05
#chrom_1    761732    rs2286139    C    T    -5.5021e-04    -7.2119e-05
#chrom_1    779322    rs4040617    G    A    -3.6596e-04    -5.0828e-05
#chrom_1    785989    rs2980300    T    C    -5.3844e-04    -7.3490e-05
#chrom_1    838555    rs4970383    A    C     9.5021e-05    1.7159e-05
#chrom_1    846808    rs4475691    T    C    -1.9991e-04    -9.6342e-06
#chrom_1    853954    rs1806509    C    A    -1.5146e-04    -1.4539e-05
#chrom_1    854250    rs7537756    G    A    -3.3800e-04    -1.9494e-05
#chrom_1    873558    rs1110052    G    T    -1.8754e-03    -1.5899e-04


/projects/0/geighei/tools/plink/plink \
      --bfile path/data/UKB/bed/6_bed_merged_snp_qc_sqc_all/ukb_hm3_snp_sqc_consent_allchr \
      --extract path/projects/UKB_PGS_plink/EA/Output/EA_new_list_clumped_SNPs_meta_23andme_UKB_noukbsibrels.txt \
      --score path/projects/UKB_LDpred/EA_new/INPUT/LD_pred_w_EA_new_meta_23andme_UKB_nosibrels_LDpred_p1.0000e+00.txt header sum 3 4 6 \
      --out path/projects/UKB_PGS_plink/EA/Output/PGS_plink_EA_new_meta_23andme_ukb_nosibssibrels_clumped

echo "Script finished"
date 









