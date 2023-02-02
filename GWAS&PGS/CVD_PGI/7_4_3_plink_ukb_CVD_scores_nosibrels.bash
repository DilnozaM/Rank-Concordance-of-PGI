#!/bin/bash
#SBATCH -t 03:00:00
#SBATCH -N 1

#cartesius
#ld pred
#pgs construction
#CVD

echo "Construct PGS"
echo "Script started"
echo "CVD UKBnosibrels"
date 

#change to the right directory
cd /path/projects/UKB_LDpred/CVD/CODE

#load python
module load 2019 
module load Python/3.6.6-foss-2018b 

#check if python works
python -h
#load other necessary packages 
pip install --user spicy
pip install --user plinkio
pip install --user h5py

# Identifying the columns to include into the construction of the ldpred score 
# Need to choose for the score flag later: marker name, reference allele, LDweight (Source: Mills et al, 2020)


head /path/projects/UKB_LDpred/CVD/INPUT/LD_pred_w_ukb_CVD_UKBnosibsrels_LDpred_p1.0000e+00.txt

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


 
#construct scores using plink , prior of 1
/projects/0/geighei/tools/plink/plink \
--bfile /path/data/UKB/bed/6_bed_merged_snp_qc_sqc_all/ukb_hm3_snp_sqc_consent_allchr \
--score /path/projects/UKB_LDpred/CVD/INPUT/LD_pred_w_ukb_CVD_UKBnosibsrels_LDpred_p1.0000e+00.txt header sum 3 4 7 \
--out /path/projects/UKB_LDpred/CVD/OUTPUT/PGS_ldpred_ukb_CVD_UKBnosibsrels


echo "Script finished"
date 











