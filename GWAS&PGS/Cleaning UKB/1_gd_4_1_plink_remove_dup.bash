#!/bin/bash
#SBATCH -t 30:00:00
#SBATCH -N 1

#Remove duplicates rsids(these are probably multi-allelic snps). plink will not be able to handle the merge otherwise
#gen file with suplicate rsids
for chr in {1..22}
do 
awk ' { print $ 2 }' /lustre5/0/geighei/data/UKB/bed/1_bed/ukb_hm3_chr${chr}.bim | uniq -d > /lustre5/0/geighei/projects/UKB_PGS_test/input/list_ukb_chr${chr}_duplicate_rsids.txt 
done


cd /lustre5/0/geighei/projects/UKB_PGS_test/input
cat list_ukb_chr*_duplicate_rsids.txt > list_ukb_allchr_duplicate_rsids.txt

cd /lustre5/0/geighei/data/UKB/bed/1_bed
	echo
	for chr in {1..22}
	do (
	/lustre5/0/geighei/tools/plink2/plink \
	--bfile /lustre5/0/geighei/data/UKB/bed/1_bed/ukb_hm3_chr${chr} \
	--exclude /lustre5/0/geighei/projects/UKB_PGS_test/input/list_ukb_allchr_duplicate_rsids.txt \
	--snps-only \
	--make-bed \
	--threads 23 \
	--out /lustre5/0/geighei/data/UKB/bed/Test_noqc_bed_merged/ukb_hm3_noqc_nodup${chr}
	) &
	done
	wait


echo "Script finished:"
date
echo

	
