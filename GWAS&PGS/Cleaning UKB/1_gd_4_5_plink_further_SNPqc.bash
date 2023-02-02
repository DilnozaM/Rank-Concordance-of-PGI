#!/bin/bash
#SBATCH -t 30:00:00
#SBATCH -N 1

#From OLD4 4_5_plink_further_SNPqc.bash

 

/path/tools/plink2/plink \
	--bfile /path/data/UKB/bed/3_bed_sqc_SNP_qc_allchr/ukb_hm3_sqc_qc_allchr \
	--make-bed \
	--snps-only \
	--geno 0.05 \
	--mind 0.05 \
	--hwe 0.000000000001 midp \
	--threads 23 \
	--out /path/data/UKB/bed/6_bed_merged_snp_qc_sqc_all/ukb_hm3_snp_sqc_allchr




