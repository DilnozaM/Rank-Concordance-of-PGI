#!/bin/bash
#SBATCH -t 30:00:00
#SBATCH -N 1

#From 4_1_create_list_snps_exclude_qc.bash
#create_list_snps_to_be_excluded
	
	
## grep list of SNPs with INFO > 0.7 & MAF > 0.01 
for i in {1..22}
do (
# get list of snps with high enough maf & info 
awk -F"\t" ' $6 > 0.01 && $8 > 0.7 { print $2 }' /path/data/UKB/mfi/ukb_mfi_chr${i}_v3.txt \
> /path/projects/UKB_processing/INPUT/list_ukb_hm3_v2_MAF01_INFO7_chr${i}.txt
) &
done
wait

wc -l /path/projects/UKB_processing/INPUT/list_ukb_hm3_v2_MAF01_INFO7_chr*.txt
#  9740190 total

cat /path/projects/UKB_processing/INPUT/list_ukb_hm3_v2_MAF01_INFO7_chr*.txt \
> /path/projects/UKB_processing/INPUT/list_ukb_hm3_v2_MAF01_INFO7_allchr.txt

wc -l /path/projects/UKB_processing/INPUT/list_ukb_hm3_v2_MAF01_INFO7_allchr.txt

echo "Script finished:"
date
echo

