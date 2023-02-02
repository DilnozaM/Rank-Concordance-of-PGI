#!/bin/bash
#SBATCH -t 07:00:00
#Adapted from Rita Pereira

#cartesius
#ld pred
#pgs construction EA in UKB


echo "Creating the weights 2"
echo "Script started" 
echo "EA NEW"
date

#change to the right directory
cd path/projects/UKB_LDpred/EA_new/CODE

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
size=$(awk '{ printf "%1.f\n",$15}' path/projects/UKB_LDpred/EA_new/INPUT/CLEANED_UKB_EA_new_sans_sibs_plus_rels_fastgwa.txt | sort -rn | head -1 )
samplesize=${size%.00}

echo "sample size is ${samplesize}"

#check if ldpred is working
echo "version 1.06"
python path/tools/ldpred/ldpred-1.0.6/LDpred.py gibbs --help


#LD with different priors 
#SNPs retained after filtering:1065146

#ld = 1065146/3000  = 355

python path/tools/ldpred/ldpred-1.0.6/LDpred.py gibbs \
--cf=path/projects/UKB_LDpred/EA_new/INPUT/LD_pred_coord_EA_new_UKB_nosibsrels \
--ldr=355 \
--ldf=path/projects/UKB_LDpred/EA_new/OUTPUT/EA_new_snp_ld_UKB_nosibrels \
--N=${samplesize} \
--f=1 \
--out=path/projects/UKB_LDpred/EA_new/INPUT/LD_pred_w_EA_new_UKB_nosibrels

echo "Script finished:"
date
echo





