#!/bin/bash
#SBATCH -t 30:00:00
#SBATCH -N 1

#qctool_merge_bed_noqc

echo "qctool_merge_bed_noqc"


#Merge files
cd /path/projects/UKB_PGS_test/input
for i in {2..22}
do
echo ukb_hm3_noqc_nodup${i}
done > list_ukb_hm3_nodup.txt

cd /path/data/UKB/bed/Test_noqc_bed_merged
/path/tools/plink2/plink \
	--bfile /path/data/UKB/bed/Test_noqc_bed_merged/ukb_hm3_noqc_nodup1 \
	--snps-only \
	--merge-list /path/input/list_ukb_hm3_nodup.txt \
	--make-bed \
	--threads 23 \
	--out /path/data/UKB/bed/Test_noqc_bed_merged/ukb_hm3_noqc_nodup

	

echo "Script finished:"
date
echo