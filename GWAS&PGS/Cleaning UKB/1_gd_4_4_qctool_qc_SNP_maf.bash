#!/bin/bash
#SBATCH -t 30:00:00
#SBATCH -N 1

#From OLD4 4_2_qctool_qc_SNP.bash
#QC_TOOL_QC_SNPs



	## 1.2 qctool ##
	# creates bed files for all UKB Snp, exclude SNPS that did not pass qc #
	echo
	echo "use qctool to filter for MAF"
	/path/qctool/build/default/qctool_v2.1-dev \
	-g /path/data/UKB/bed/Test_noqc_bed_merged/ukb_hm3_noqc_nodup.bed \
	-og /path/data/UKB/bed/3_bed_sqc_SNP_qc_allchr/ukb_hm3_sqc_qc_allchr.bed  \
	-incl-rsids /path/projects/UKB_processing/INPUT/list_ukb_hm3_v2_MAF01_INFO7_allchr.txt \
	-log /path/data/UKB/bed/3_bed_sqc_SNP_qc_allchr/ukb_imp_allchr_v2_convert_bed.log
	

echo "Script finished:"
date
echo







