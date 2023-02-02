#!/bin/bash
#SBATCH -t 30:00:00
#SBATCH -N 1

#From OLD4 3_2_plink_remove_samples_qc_nonconsent.bash

#Remove non-consent individuals with failed qc

echo "4_6_plink_remove_nonconsent"

#create one file with all the samples id to be removed in STATA

	#count individuals to be excluded
	wc -l /path/data/UKB/sqc/list_samples_qc_non_consent_UKBB_v2.txt
	#41069
	
	
	#check for duplicates
	sort /path/data/UKB/sqc/list_samples_qc_non_consent_UKBB_v2.txt | uniq | wc -l
	#41069, so no duplicates
	


/path/tools/plink/plink \
	--bfile /path/data/UKB/bed/6_bed_merged_snp_qc_sqc_all/ukb_hm3_snp_sqc_allchr \
	--remove /path/data/UKB/sqc/list_samples_qc_non_consent_UKBB_v2.txt \
	--make-bed \
	--out /path/data/UKB/bed/6_bed_merged_snp_qc_sqc_all/ukb_hm3_snp_sqc_consent_allchr



echo "Script finished:"
date
echo