#!/bin/bash
#SBATCH -t 5-00:00:00
#SBATCH -N 1

#2_Create a sample file

#make a folder to store snps
cd /path
#mkdir hm3_snps
cd hm3_snps

#download HM3 snps
# hm3 CEU snps (list)
#wget ftp://ftp.ncbi.nlm.nih.gov/hapmap/phase_3/hapmap3_reformatted/CEU.hmap.gz
gunzip CEU*
awk ' NR > 1 { print $1}' CEU.hmap | head
awk ' NR > 1 { print $1}' CEU.hmap > HM3_rsids_CEU.txt
head HM3_rsids_CEU.txt

head CEU.skip

grep -f rs5746071 HM3_rsids_CEU.txt

for snp in rs11573221 rs11573230 rs2020883 rs11573262 rs17837950
do
echo "grepping snp ${snp} from CEU.skip"
grep ${snp} HM3_rsids_CEU.txt
done


# file with indels. check if these are not in full file
#wget ftp://ftp.ncbi.nlm.nih.gov/hapmap/phase_3/hapmap3_reformatted/CEU.skip
#this didnt work but i copied it manually


#make a folder for the .bed files
mkdir /path/data/UKB/bed
mkdir /path/data/UKB/bgen_hm3

#extract HM3 SNPS only and create a sample file
for C in {1..22}; do
(
echo "use qctool to create sample file and hm3 subset for chromosome ${C}"
/path/qctool/build/default/qctool_v2.1-dev \
-g /path/data/UKB/imp/ukb_imp_chr${C}_v3.bgen \
-incl-rsids /path/data/UKB/hm3_snps/HM3_rsids_CEU.txt \
-og /path/data/UKB/bgen_hm3/ukb_hm3_${C}.bgen \
-os /path/data/UKB/bgen_hm3/ukb_hm3_${C}.sample
echo 
echo "chromosome ${C} is complete"
) > /lpath/UKB_processing/CODE/qctool_chr${C}.log &
done
wait





