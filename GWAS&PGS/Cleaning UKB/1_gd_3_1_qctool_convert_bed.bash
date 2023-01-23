#!/bin/bash
#SBATCH -t 30:00:00
#SBATCH -N 1

#qctool_CONVERT_TO_BED

echo "3_qctool_CONVERT_TO_BED"

#create one file with all the samples id to be removed

	#count individuals to be excluded
	wc -l /lustre5/0/geighei/data/UKB/sqc/list_samples_qc_non_consent_UKBB.txt
	#56296
	
	
	#check for duplicates
	sort /lustre5/0/geighei/data/UKB/sqc/list_samples_qc_non_consent_UKBB.txt | uniq | wc -l
	#56296, so no duplicates
	

	
	## 1.2 qctool ##
	# creates bed files for all UKB non-HRC snps #
	echo
	echo
	for chr in {1..22}
	do (
	/lustre5/0/geighei/tools/qctool_fleur/qctool/build/default/qctool_v2.1-dev \
	-s /lustre5/0/geighei/data/UKB/bgen_hm3/ukb_hm3_${chr}.sample \
	-g /lustre5/0/geighei/data/UKB/bgen_hm3/ukb_hm3_${chr}.bgen \
	-og /lustre5/0/geighei/data/UKB/bed/1_bed/ukb_hm3_chr${chr}.bed  \
	-log /lustre5/0/geighei/projects/UKB_processing/CODE/ukb_imp_chr${chr}_convert_bed.log
	) &
	done
	wait	
	
echo "Script finished:"
date
echo