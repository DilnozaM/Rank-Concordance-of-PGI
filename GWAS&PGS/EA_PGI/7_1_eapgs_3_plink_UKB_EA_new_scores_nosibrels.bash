#!/bin/bash
#SBATCH -t 03:00:00
#SBATCH -N 1

#cartesius
#ld pred
#pgs construction
#EA

echo "Construct PGS"
echo "Script started"
date 

#change to the right directory
cd /lustre5/0/geighei/projects/UKB_LDpred/EA_new/CODE

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

head /lustre5/0/geighei/projects/UKB_LDpred/EA_new/INPUT/LD_pred_w_EA_new_UKB_nosibrels_LDpred_p1.0000e+00.txt

#1chrom     2pos      3sid         4nt1 5nt2 6raw_beta      7ldpred_beta
#chrom_1    754182    rs3131969    A    G    -1.0636e-03    -1.2073e-04
#chrom_1    761732    rs2286139    C    T    -9.9841e-04    -1.0657e-04
#chrom_1    779322    rs4040617    G    A    -6.6415e-04    -6.6663e-05
#chrom_1    785989    rs2980300    T    C    -9.7699e-04    -1.0639e-04
#chrom_1    838555    rs4970383    A    C    -2.3781e-04    -1.4083e-05
#chrom_1    846808    rs4475691    T    C     1.7329e-04    3.9644e-05
#chrom_1    853954    rs1806509    C    A    -2.0278e-05    9.2595e-07
#chrom_1    854250    rs7537756    G    A    -1.7327e-04    4.6126e-06
#chrom_1    873558    rs1110052    G    T    -3.5101e-03    -2.8783e-04

#construct scores using plink , prior of 1
/projects/0/geighei/tools/plink/plink \
--bfile /lustre5/0/geighei/data/UKB/bed/6_bed_merged_snp_qc_sqc_all/ukb_hm3_snp_sqc_consent_allchr \
--score /lustre5/0/geighei/projects/UKB_LDpred/EA_new/INPUT/LD_pred_w_EA_new_UKB_nosibrels_LDpred_p1.0000e+00.txt header sum 3 4 7 \
--out /lustre5/0/geighei/projects/UKB_LDpred/EA_new/OUTPUT/PGS_ldpred_UKB_EA_new_nosibsrel_p1


echo "Script finished"
date 











