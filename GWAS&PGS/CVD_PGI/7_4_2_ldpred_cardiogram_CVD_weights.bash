#!/bin/bash
#SBATCH -t 07:00:00
#Adapted from Rita Pereira

#cartesius
#ld pred
#pgs construction CVD


echo "Creating the weights 2"
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
pip3 install --user spicy
pip3 install --user scipy
pip3 install --user plinkio
pip3 install --user h5py


#Number of Observations rounded, just use the max number of observations per SNP
#This is calculated by using effective sample size formula on n_cases and n_controls in Cardiogram readme
size=81486
samplesize=${size%.00}
echo "sample size is ${samplesize}"


#check if ldpred is working
echo "version 1.06"
python /lustre5/0/geighei/tools/ldpred/ldpred-1.0.6/LDpred.py gibbs --help


#LD with different priors 
#SNPs retained after filtering:1062641

#ld = 1062641/3000  = 354

python /lustre5/0/geighei/tools/ldpred/ldpred-1.0.6/LDpred.py gibbs \
--cf=/lustre5/0/geighei/projects/UKB_LDpred/CVD/INPUT/LD_pred_coord_cardiogram_CVD \
--ldr=354 \
--ldf=/lustre5/0/geighei/projects/UKB_LDpred/CVD/OUTPUT/CVD_cardiogram_snp_ld \
--N=${samplesize} \
--f=1 \
--out=/lustre5/0/geighei/projects/UKB_LDpred/CVD/INPUT/LD_pred_w_cardiogram_CVD

echo "Script finished:"
date
echo





