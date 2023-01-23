#!/bin/bash
#SBATCH -t 30:00:00
#SBATCH -N 1

#From OLD4 4_2_qctool_qc_SNP.bash
#QC_TOOL_QC_SNPs



	## 1.2 qctool ##
	# creates bed files for all UKB Snp, exclude SNPS that did not pass qc #
	echo
	echo "use qctool to filter for MAF"
	/lustre5/0/geighei/tools/qctool_fleur/qctool/build/default/qctool_v2.1-dev \
	-g /lustre5/0/geighei/data/UKB/bed/Test_noqc_bed_merged/ukb_hm3_noqc_nodup.bed \
	-og /lustre5/0/geighei/data/UKB/bed/3_bed_sqc_SNP_qc_allchr/ukb_hm3_sqc_qc_allchr.bed  \
	-incl-rsids /lustre5/0/geighei/projects/UKB_processing/INPUT/list_ukb_hm3_v2_MAF01_INFO7_allchr.txt \
	-log /lustre5/0/geighei/data/UKB/bed/3_bed_sqc_SNP_qc_allchr/ukb_imp_allchr_v2_convert_bed.log
	

echo "Script finished:"
date
echo








	## 1.2 qctool ##
	# creates bed files for all UKB Snp, exclude SNPS that did not pass qc #
	#echo
	#echo
	#for chr in {1..22}
	#do (
	#/lustre5/0/geighei/tools/qctool_fleur/qctool/build/default/qctool_v2.1-dev \
	#-g /lustre5/0/geighei/data/UKB/bed/2_bed_sqc/ukb_hm3_sqc_chr${chr}.bed \
	#-og /lustre5/0/geighei/data/UKB/bed/3_bed_sqc_SNP_qc/ukb_hm3_sqc_qc_chr${chr}.bed  \
	#-incl-rsids /lustre5/0/geighei/projects/UKB_processing/INPUT/list_ukb_hm3_v2_MAF01_INFO7_chr${chr}.txt \
	#-log /lustre5/0/geighei/data/UKB/bed/3_bed_sqc_SNP_qc/ukb_imp_chr${chr}_v2_convert_bed.log
	#) &
	#done
	#wait

