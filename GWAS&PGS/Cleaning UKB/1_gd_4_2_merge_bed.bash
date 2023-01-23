#!/bin/bash
#SBATCH -t 30:00:00
#SBATCH -N 1

#qctool_merge_bed_noqc

echo "qctool_merge_bed_noqc"


#Merge files
cd /lustre5/0/geighei/projects/UKB_PGS_test/input
for i in {2..22}
do
echo ukb_hm3_noqc_nodup${i}
done > list_ukb_hm3_nodup.txt

cd /lustre5/0/geighei/data/UKB/bed/Test_noqc_bed_merged
/lustre5/0/geighei/tools/plink2/plink \
	--bfile /lustre5/0/geighei/data/UKB/bed/Test_noqc_bed_merged/ukb_hm3_noqc_nodup1 \
	--snps-only \
	--merge-list /lustre5/0/geighei/projects/UKB_PGS_test/input/list_ukb_hm3_nodup.txt \
	--make-bed \
	--threads 23 \
	--out /lustre5/0/geighei/data/UKB/bed/Test_noqc_bed_merged/ukb_hm3_noqc_nodup

	

echo "Script finished:"
date
echo