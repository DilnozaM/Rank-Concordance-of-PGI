#!/bin/bash
#SBATCH -t 07:00:00
#Adapted from Rita Pereira

#cartesius
#ld pred
#pgs construction CVD in UKB


echo "Creating the weights 2"
echo "Script started" 
echo "CVD UKB"
date

#change to the right directory
cd /lustre5/0/geighei/projects/UKB_LDpred/CVD/CODE

#load python
module load 2019 
module load Python/3.6.6-foss-2018b 

#check if python works
python -h

#load other necessary packages 
pip3 install --user spicy
pip3 install --user scipy
pip3 install --user plinkio
pip3 install --user h5py


#Number of Observations rounded, just use the max number of observations per SNP
size=$(awk '{ printf "%1.f\n",$15}' /lustre5/0/geighei/projects/UKB_LDpred/CVD/INPUT/CLEANED_ukb_CVD_fastgwa_mlm_excl_sibs_sibrels.txt | sort -rn | head -1 )
samplesize=${size%.00}
echo "sample size is ${samplesize}"


#check if ldpred is working
echo "version 1.06"
python /lustre5/0/geighei/tools/ldpred/ldpred-1.0.6/LDpred.py gibbs --help


#LD with different priors 
#SNPs retained after filtering:1065146

#ld = 1065144/3000  = 355

python /lustre5/0/geighei/tools/ldpred/ldpred-1.0.6/LDpred.py gibbs \
--cf=/lustre5/0/geighei/projects/UKB_LDpred/CVD/INPUT/LD_pred_coord_ukb_CVD_UKBnosibsrels \
--ldr=355 \
--ldf=/lustre5/0/geighei/projects/UKB_LDpred/CVD/OUTPUT/ukb_snp_ld_CVD_UKBnosibsrels \
--N=${samplesize} \
--f=1 \
--out=/lustre5/0/geighei/projects/UKB_LDpred/CVD/INPUT/LD_pred_w_ukb_CVD_UKBnosibsrels

echo "Script finished:"
date
echo





