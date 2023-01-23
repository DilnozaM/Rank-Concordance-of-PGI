#!/bin/bash
#SBATCH -t 06:00:00
#SBATCH -N 1
#Adapted from Rita Pereira

echo "PGS_EA_UKB_nosibs_norel_sample1_coord"
echo "Script started"
echo "UKB+23andMe-UKBsibs&relatives"
date

#change to the right directory
cd /lustre5/0/geighei/projects/UKB_LDpred/EA/CODE

#load python
module load 2019 
module load Python/3.6.6-foss-2018b 

#check if python works
python -h

#load other necessary packages 
pip install --user spicy
pip install --user plinkio
pip install --user h5py


#check if ldpred is working
echo "version 1.06"
python /lustre5/0/geighei/tools/ldpred/ldpred-1.0.6/LDpred.py coord --help 

				  
#Number of Observations rounded, just use the max number of observations per SNP
size=$(awk '{ printf "%1.f\n",$10}' /lustre5/0/geighei/projects/EA_METAL/OUTPUT/GWAS_ea_new_meta_23andme_UKB_UKBnosibsrels.txt | sort -rn | head -1 )
samplesize=${size%.00}
echo "sample size is ${samplesize}"


#coordinate files, gf and vbim will be the UKBrefpanel 
python /lustre5/0/geighei/tools/ldpred/ldpred-1.0.6/LDpred.py coord \
--gf=/lustre5/0/geighei/data/UKB/ref_panel_v2/ukb_ref_panel_30k \
--ssf-format=STANDARD \
--ssf=/lustre5/0/geighei/projects/UKB_LDpred/EA_new/INPUT/EA_new_meta_23andme_UKB_sanssibsplusrels_fastgwa_ldpred_format.txt \
--N=${samplesize} \
--only-hm3 \
--beta \
--max-freq-discrep 1 \
--vbim=/lustre5/0/geighei/data/UKB/ref_panel_v2/ukb_ref_panel_30k.bim \
--out=/lustre5/0/geighei/projects/UKB_LDpred/EA_new/INPUT/LD_pred_coord_EA_new_meta_UKB_23andme_nosibsrels


echo "Script finished:"
date
echo
