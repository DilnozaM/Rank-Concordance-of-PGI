#!/bin/bash
#SBATCH -t 00:08:00

module load pre2019
module load python/2.7.9
pip install --user pandas==0.17.0
pip install --user numpy==1.16.0

# EA

cd /path/projects/UKB_GWAS/EA_new/OUTPUT

# Munge Data (1 Sibling) (on Cartesius)
python /path/tools/ldsc/munge_sumstats.py \
--sumstats ukb_ea_new_fastgwa_mlm_onesib_resid_qc.fastGWA \
--out ukb_ea_new_fastgwa_mlm_onesib_resid_qc_munged \
--merge-alleles /path/tools/ldsc/w_hm3.snplist

# Run LDSC (on personal laptop)
python ldsc.py --h2 ukb_ea_new_fastgwa_mlm_onesib_resid_qc_munged.sumstats.txt --ref-ld-chr eur_w_ld_chr/ --out ukb_ea_new_fastgwa_mlm_onesib_resid_qc_munged --w-ld-chr eur_w_ld_chr/

# Height

cd /path/projects/UKB_GWAS/Height/OUTPUT

# Munge Data (1 Sibling) (on Cartesius)
python /path/tools/ldsc/munge_sumstats.py \
--sumstats ukb_height_fastgwa_mlm_onesib.fastGWA \
--out ukb_height_fastgwa_mlm_onesib_munged \
--merge-alleles /path/tools/ldsc/w_hm3.snplist

# Run LDSC (on personal laptop)
python ldsc.py --h2 ukb_height_fastgwa_mlm_onesib_munged.sumstats.txt --ref-ld-chr eur_w_ld_chr/ --out ukb_height_fastgwa_mlm_onesib_munged --w-ld-chr eur_w_ld_chr/ 

# GREML

cd /path/projects/UKB_GREML

awk -v OFS=" " '{print $1, $1, $3}' /path/data/UKB/key/ukb41382_cal_chr22_v2_s488288_ssgac_ids_ukb_ids.txt > UPDATE_IDS.txt
sed -i '1d' UPDATE_IDS.txt
cut -f3 -d ' ' UPDATE_IDS.txt > UPDATE_IDS_4thC.txt 
sed -i 's/sample_//g' UPDATE_IDS_4thC.txt 
awk -F, '{$1=$1+1;print}' OFS=' ' UPDATE_IDS_4thC.txt > UPDATE_IDS_4thC_v2.txt
paste -d ' ' UPDATE_IDS.txt UPDATE_IDS_4thC_v2.txt > IDS_COMBINED.txt
cut -d ' ' -f4,3,2,1  IDS_COMBINED.txt > IDS_COMBINED_TO_UPDATE.txt
awk -F, '{$4 $3 $2 $1;print}' IDS_COMBINED.txt > IDS_COMBINED_TO_UPDATE.txt
awk '{print $4,$3,$2,$1}' IDS_COMBINED.txt > IDS_COMBINED_TO_UPDATE.txt

# EA
/projects/0/geighei/tools/plink/plink --bfile /path/data/UKB/bed/6_bed_merged_snp_qc_sqc_all/ukb_hm3_snp_sqc_allchr --make-bed --keep /path/projects/UKB_GWAS/EA_new/INPUT/UKB_EA_new_resid_pheno_onesib.txt --update-ids IDS_COMBINED_TO_UPDATE.txt --out UKB_oneSIB_EA_NEW
/projects/0/geighei/tools/plink/plink --bfile UKB_oneSIB_EA_NEW --make-grm-bin --out UKB_oneSIB_EA_NEW
/path/tools/gcta_1.93.0beta/gcta64 --bfile UKB_oneSIB_EA_NEW --make-grm --out UKB_oneSIB_EA_NEW --threads 15
/path/tools/gcta_1.93.0beta/gcta64 --grm UKB_oneSIB_EA_NEW --pheno /path/projects/UKB_GWAS/EA_new/INPUT/UKB_EA_new_resid_pheno_onesib.txt --reml --out UKB_oneSIB_EA_NEW --threads 15
/path/tools/gcta_1.93.0beta/gcta64 --grm UKB_oneSIB_EA_NEW --pheno /path/projects/UKB_GWAS/EA_new/INPUT/UKB_EA_new_resid_pheno_onesib.txt --reml --out UKB_oneSIB_EA_NEW_cutoff --grm-cutoff 0.025 --threads 15

# Height
/projects/0/geighei/tools/plink/plink --bfile /path/data/UKB/bed/6_bed_merged_snp_qc_sqc_all/ukb_hm3_snp_sqc_allchr --make-bed --keep /path/projects/UKB_GWAS/Height/INPUT/UKB_height_resid_pheno_onesib.txt --update-ids IDS_COMBINED_TO_UPDATE.txt --out UKB_oneSIB_HEIGHT
/projects/0/geighei/tools/plink/plink --bfile UKB_oneSIB_HEIGHT --make-grm-bin --out UKB_oneSIB_HEIGHT
/path/tools/gcta_1.93.0beta/gcta64 --bfile UKB_oneSIB_HEIGHT --make-grm --out UKB_oneSIB_HEIGHT --threads 15
/path/tools/gcta_1.93.0beta/gcta64 --grm UKB_oneSIB_HEIGHT --pheno /path/projects/UKB_GWAS/Height/INPUT/UKB_height_resid_pheno_onesib.txt --reml --out UKB_oneSIB_HEIGHT --threads 15
/path/tools/gcta_1.93.0beta/gcta64 --grm UKB_oneSIB_HEIGHT --pheno /path/projects/UKB_GWAS/Height/INPUT/UKB_height_resid_pheno_onesib.txt --reml --out UKB_oneSIB_HEIGHT_cutoff --grm-cutoff 0.025 --threads 15

