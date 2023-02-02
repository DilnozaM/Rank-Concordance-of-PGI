#!/bin/bash
#SBATCH -t 06:00:00
#SBATCH -N 1

#cartesius
#ld pred
#pgs construction
#EA

echo "Construct PGS"
echo "Script started"
date 

#change to the right directory
cd path/projects/UKB_LDpred/EA/CODE

#load plink
module load 2019 
module load Python/3.6.6-foss-2018b 

#check if plink works
python -h
#load other necessary packages 
pip install --user spicy
pip install --user plinkio
pip install --user h5py

# Identifying the columns to include into the construction of the ldpred score 
# Need to choose for the score flag later: marker name, reference allele, LDweight (Source: Mills et al, 2020)

head path/projects/UKB_LDpred/EA/INPUT/LD_pred_w_EA_23andme_LDpred_p1.0000e+00.txt

#1chrom     2pos      3sid         4nt1 5nt2 6raw_beta     7ldpred_beta
#chrom_1    838555    rs4970383    A    C    3.9548e-04    3.6977e-05
#chrom_1    846808    rs4475691    T    C    -5.6033e-04    -4.5432e-05
#chrom_1    853954    rs1806509    C    A    -2.9871e-04    -2.6225e-05
#chrom_1    854250    rs7537756    G    A    -5.6001e-04    -3.8693e-05
#chrom_1    873558    rs1110052    G    T    -9.9009e-04    -7.0754e-05
#chrom_1    879317    rs7523549    T    C    3.1869e-03    5.3569e-04
#chrom_1    880238    rs3748592    A    G    2.7102e-03    3.1008e-04
#chrom_1    880390    rs3748593    A    C    3.2325e-03    5.4665e-04
#chrom_1    882033    rs2272756    A    G    -9.8979e-04    -7.5458e-05

 
#construct scores using plink , prior of 1
/projects/0/geighei/tools/plink/plink \
--bfile path/data/UKB/bed/6_bed_merged_snp_qc_sqc_all/ukb_hm3_snp_sqc_consent_allchr \
--score path/projects/UKB_LDpred/EA/INPUT/LD_pred_w_EA_23andme_LDpred_p1.0000e+00.txt header sum 3 4 7 \
--out path/projects/UKB_LDpred/EA/OUTPUT/PGS_ldpred_EA_23andme_p1


echo "Script finished"
date 









