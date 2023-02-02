#!/bin/bash
#SBATCH -t 06:00:00
#SBATCH -N 1
#Adapted from Rita Pereira

#cartesius
#ld pred
#pgs construction EA in UKB


echo "Creating the weights 2"
echo "Script started" 
date

#change to the right directory
cd path/projects/UKB_LDpred/EA/CODE

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


#Number of Observations, just use the max number of observations per SNP
size=$(awk '{ printf "%1.f\n",$12}' path/projects/UKB_LDpred/EA/INPUT/CLEANED_23andme_EA_allsnpinfo_allstat_noflips.txt | sort -rn | head -1 )
samplesize=${size%.00}

echo "sample size is ${samplesize}"

#check if ldpred is working
echo "version 1.06"
python path/tools/ldpred/ldpred-1.0.6/LDpred.py gibbs --help


#LD with different priors 
#SNPs retained after filtering:1057143

#ld = 1057143/3000  = 352

python path/tools/ldpred/ldpred-1.0.6/LDpred.py gibbs \
--cf=path/projects/UKB_LDpred/EA/INPUT/LD_pred_coord_EA_23andme \
--ldr=352 \
--ldf=path/projects/UKB_LDpred/EA/INPUT/snp_ld_23andme \
--N=${samplesize} \
--f=1 \
--out=path/projects/UKB_LDpred/EA/INPUT/LD_pred_w_EA_23andme

echo "Script finished:"
date
echo





