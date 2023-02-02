#!/bin/bash
#SBATCH -t 5-00:00:00
#SBATCH -N 1

#From OLD4 5_plink_reference_30k.bash 
#Plink reference panel 30k

cd /path/data/UKB/ref_panel_v2
dos2unix ID_fam_ukb_reference_30k.txt


#Attention, the reference already has the people in kinship excluded
/path/tools/plink2/plink \
	--bfile /path/data/UKB/bed/6_bed_merged_snp_qc_sqc_all/ukb_hm3_snp_sqc_consent_allchr \
	--keep ID_fam_ukb_reference_30k.txt \
	--make-bed \
	--out /path/data/UKB/ref_panel_v2/ukb_ref_panel_30k

echo "Script finished:"
date
echo



