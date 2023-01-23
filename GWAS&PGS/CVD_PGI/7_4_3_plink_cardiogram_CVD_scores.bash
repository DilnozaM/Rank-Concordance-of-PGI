#!/bin/bash
#SBATCH -t 03:00:00
#SBATCH -N 1

#cartesius
#ld pred
#pgs construction
#CVD

echo "Construct PGS"
echo "Script started"
echo "CVD Cardiogram"
date 

#change to the right directory
cd /lustre5/0/geighei/projects/UKB_LDpred/CVD/CODE

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


head /lustre5/0/geighei/projects/UKB_LDpred/CVD/INPUT/LD_pred_w_cardiogram_CVD_LDpred_p1.0000e+00.txt

#1chrom     2pos      3sid        4nt1  5nt2 6raw_beta     7ldpred_beta
#chrom_1    754182    rs3131969    A    G    -1.3799e-03    -1.8906e-05
#chrom_1    761732    rs2286139    C    T    1.0838e-03    1.3287e-05
#chrom_1    779322    rs4040617    G    A    5.7440e-04    7.2737e-06
#chrom_1    785989    rs2980300    T    C    2.1024e-04    2.3814e-06
#chrom_1    918384    rs13303118   G    T    7.2145e-03    6.3728e-05
#chrom_1    944564    rs3128117    C    T    1.0300e-02    9.2140e-05
#chrom_1    950243    rs1891906    C    A    9.4325e-03    8.4305e-05
#chrom_1    959842    rs2710888    T    C    4.0938e-03    3.5606e-05
#chrom_1    962606    rs4970393    G    A    6.0228e-03    5.1929e-05


 
#construct scores using plink , prior of 1
/projects/0/geighei/tools/plink/plink \
--bfile /lustre5/0/geighei/data/UKB/bed/6_bed_merged_snp_qc_sqc_all/ukb_hm3_snp_sqc_consent_allchr \
--score /lustre5/0/geighei/projects/UKB_LDpred/CVD/INPUT/LD_pred_w_cardiogram_CVD_LDpred_p1.0000e+00.txt header sum 3 4 7 \
--out /lustre5/0/geighei/projects/UKB_LDpred/CVD/OUTPUT/PGS_ldpred_cardiogram_CVD


echo "Script finished"
date 











