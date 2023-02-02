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
cd path/projects/UKB_LDpred/EA_new/CODE

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


#construct scores using plink , prior of 1
/projects/0/geighei/tools/plink/plink \
--bfile path/data/UKB/bed/6_bed_merged_snp_qc_sqc_all/ukb_hm3_snp_sqc_consent_allchr \
--score path/projects/UKB_LDpred/EA_new/INPUT/LD_pred_w_EA_new_meta_23andme_UKB_nosibrels_LDpred_p1.0000e+00.txt header sum 3 4 7 \
--out path/projects/UKB_LDpred/EA_new/OUTPUT/PGS_ldpred_meta_23andme_UKB_EA_new_nosibsrel_p1


echo "Script finished"
date 











