#!/bin/bash
#SBATCH -t 06:00:00
#SBATCH -N 1

#cartesius
#pgs construction
#EA

echo "Construct PGS"
echo "Script started"
date 

#change to the right directory
cd path/projects/UKB_PGS_plink/EA/Code

#load plink
module load 2019 
module load Python/3.6.6-foss-2018b 


# Identifying the columns to include into the construction of the ldpred score 
# Need to choose for the score flag later: marker name, reference allele, weight (gwas beta or ld) (Source: Mills et al, 2020)

head path/projects/UKB_LDpred/EA/INPUT/CLEANED_23andme_EA_allsnpinfo_allstat_noflips.txt


#1cptid	        2rsID	        3CHR	4POS	  5EFFECT_ALLEL 6OTHER_ALLELE	7EAF	8BETA	        9SE	        10PVAL	        11Z	                12N	13INFO	14BETA_stand	        15SE_stand
#10:100003242	rs12258651	10	100003242	T	G	        0.88366	0.00762852	0.00951727	0.422803	0.801544980861108	365536	0.99739	0.00292375310200588	0.00364764694660661
#10:100003516	rs185989018	10	100003516	G	A	        0.99518	-0.00239527	0.04831416	0.960458	-0.0495769770187456	365536	0.83089	-0.000837193075643265	0.01688673101885
#10:100003785	rs1359508	10	100003785	T	C	        0.64105	0.0119303	0.00636644	0.0609327	1.87393582598752	365536	0.99958	0.00456890057805143	0.00243813075917033
#10:100004360	rs1048754	10	100004360	G	A	        0.79517	-0.00444206	0.00757184	0.557423	-0.586655291184177	365536	0.99953	-0.00170010655080453	0.00289796508503797
#10:100004441	rs1048757	10	100004441	G	C	        0.36182	-0.0109343	0.00635697	0.085414	-1.72004901706316	365536	0.99957	-0.00418642069405257	0.0024338961579133
#10:100004906	rs3750595	10	100004906	C	A	        0.56693	-0.0071834	0.00617125	0.244406	-1.16401053271217	365536	0.99988	-0.00274747067217883	0.00236034863514264
#10:100004996	rs2025625	10	100004996	G	A	        0.64107	0.0119499	0.00636648	0.0605118	1.87700267651826	365536	0.99958	0.00457643407035631	0.00243816065241065
#10:10000586	rs190955300	10	10000586	T	C	        0.99383	-0.0109532	0.0537386	0.838487	-0.203823694699899	365536	0.60329	-0.00304421948349538	0.0149355524536907
#10:100007243	rs4919189	10	100007243	T	C	        0.00181	0.102365	0.07756841	0.186933	1.31967382082474


#Clump the scores using the PRcise default thresholds 
/projects/0/geighei/tools/plink/plink \
      --bfile path/data/UKB/bed/6_bed_merged_snp_qc_sqc_all/ukb_hm3_snp_sqc_consent_allchr \
      --clump path/projects/UKB_LDpred/EA/INPUT/CLEANED_23andme_EA_allsnpinfo_allstat_noflips.txt \
      --clump-p1 1 \
      --clump-kb 250 \
      --clump-r2 0.10 \
      --clump-p2 1 \
      --clump-snp-field rsID \
      --clump-field PVAL \
      --out path/projects/UKB_PGS_plink/EA/Output/EA_clumped_23andme


#Now make a list of the clumped SNPs
head path/projects/UKB_PGS_plink/EA/Output/EA_clumped_23andme.clumped


awk '{ print $3 }' path/projects/UKB_PGS_plink/EA/Output/EA_clumped_23andme.clumped > path/projects/UKB_PGS_plink/Output/EA_list_clumped_SNPs_23andme.txt

#Remove the column name "SNP"
sed -i '1d' path/projects/UKB_PGS_plink/EA/Output/EA_list_clumped_SNPs_23andme.txt

#count the number of SNPs included
grep -c rs path/projects/UKB_PGS_plink/EA/Output/EA_list_clumped_SNPs_23andme.txt
#109263 
#Is this a normal thing? NB: the job was killed, see the log file in output folder

#construct the poly score after removing the snps in the same region; 
#Need to choose for the score flag later: marker name, reference allele, weight (ld or gwas beta) (Source: Mills et al, 2020)


/projects/0/geighei/tools/plink/plink \
      --bfile path/data/UKB/bed/6_bed_merged_snp_qc_sqc_all/ukb_hm3_snp_sqc_consent_allchr \
      --extract path/projects/UKB_PGS_plink/EA/Output/EA_list_clumped_SNPs_23andme.txt \
      --score path/projects/UKB_LDpred/EA/INPUT/CLEANED_23andme_EA_allsnpinfo_allstat_noflips.txt header sum 2 5 8 \
      --out path/projects/UKB_PGS_plink/EA/Output/PGS_plink_EA_23andme_clumped

PGS_plink_EA_23andme_ukb_nosibssibrels_clumped

echo "Script finished"
date 









