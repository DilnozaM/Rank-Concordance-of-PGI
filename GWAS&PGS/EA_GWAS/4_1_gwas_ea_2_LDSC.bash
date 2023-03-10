#!/bin/bash
#SBATCH -t 00:08:00

module load pre2019
module load python/2.7.9
pip install --user pandas==0.17.0
pip install --user numpy==1.16.0

cd /path/projects/UKB_GWAS/EA_new/OUTPUT

# Munge Data (1 Sibling)
python /path/tools/ldsc/munge_sumstats.py \
--sumstats ukb_ea_new_fastgwa_mlm_onesib_resid_qc.fastGWA \
--out ukb_ea_new_fastgwa_mlm_onesib_resid_qc_munged \
--merge-alleles /path/tools/ldsc/w_hm3.snplist

