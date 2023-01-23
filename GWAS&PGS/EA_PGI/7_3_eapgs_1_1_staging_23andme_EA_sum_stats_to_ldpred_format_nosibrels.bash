#!/bin/bash
#SBATCH -t 03:00:00
#SBATCH -N 1
#Adapted from Rita Pereira 

echo "Change the sum stats to ldpred format"
echo "Script started"
date 

#change to the right directory
cd /lustre5/0/geighei/projects/UKB_LDpred/EA/CODE

#load python
module load 2019 
module load Python/3.6.6-foss-2018b 

#check if python works
python -h

#load other necessary packages 
pip install --user spicy
pip install --user plinkio
pip install --user h5py


#check if ldpred is working
echo "version 1.06"
python /lustre5/0/geighei/tools/ldpred/ldpred-1.0.6/LDpred.py coord --help

#Unzip the sumstats
gunzip -c /lustre5/0/geighei/projects/23andme/EA/1_QC/OUTPUT/CLEANED.education_years_5.1_allsnpinfo_allstat_noflips.dat.gz > /lustre5/0/geighei/projects/UKB_LDpred/EA/INPUT/CLEANED_23andme_EA_allsnpinfo_allstat_noflips.txt


#Organize sum stats 
head /lustre5/0/geighei/projects/UKB_LDpred/EA/INPUT/CLEANED_23andme_EA_allsnpinfo_allstat_noflips.txt


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

## LDpred REQUIRES THE FOLLOWING FORMAT:
## chr     pos     ref     alt     reffrq  info    rs          pval    effalt
## chr1    1020428  C       T     0.85083  0.98732 rs6687776   0.0587  -0.014



#Checking which one is the reference allele 
# EFFECT_ALLLELE is the reference allele. 


# column separator is either a : or a tab 
#chr = $3
#pos = $4
#ref = EFFECT_ALLELE = $5
#alt = OTHER_ALLELE = $6
#reff freq = EAF = $7
#info = $13
#rs = rsid = $2
#pval = $10
#effalt = $8
awk -F" " 'BEGIN{OFS="\t"; print "chr", "pos", "ref", "alt", "reffrq", "info", "rs", "pval", "effalt"} 
                 {if(NR>1) {print "chr"$3, $4, $5, $6, $7, $13, $2, $10, $8}}' OFS="\t" \
                  /lustre5/0/geighei/projects/UKB_LDpred/EA/INPUT/CLEANED_23andme_EA_allsnpinfo_allstat_noflips.txt > /lustre5/0/geighei/projects/UKB_LDpred/EA/INPUT/CLEANED_23andme_EA_allsnpinfo_allstat_noflips_ldpred_format.txt


#Formula for beta=z-score/sqrt(N*2*MAF*(1-MAF))

echo "head sum stats"
head /lustre5/0/geighei/projects/UKB_LDpred/EA/INPUT/CLEANED_23andme_EA_allsnpinfo_allstat_noflips_ldpred_format.txt
#chr	pos	ref	alt	reffrq	info	rs	pval	effalt
#chr10	100003242	T	G	0.88366	0.99739	rs12258651	0.422803	0.00762852
#chr10	100003516	G	A	0.99518	0.83089	rs185989018	0.960458	-0.00239527
#chr10	100003785	T	C	0.64105	0.99958	rs1359508	0.0609327	0.0119303
#chr10	100004360	G	A	0.79517	0.99953	rs1048754	0.557423	-0.00444206
#chr10	100004441	G	C	0.36182	0.99957	rs1048757	0.085414	-0.0109343
#chr10	100004906	C	A	0.56693	0.99988	rs3750595	0.244406	-0.0071834
#chr10	100004996	G	A	0.64107	0.99958	rs2025625	0.0605118	0.0119499
#chr10	10000586	T	C	0.99383	0.60329	rs190955300	0.838487	-0.0109532
#chr10	100007243	T	C	0.00181	0.96132	rs4919189	0.186933	0.102365


echo "tail sum stats"
tail /lustre5/0/geighei/projects/UKB_LDpred/EA/INPUT/CLEANED_23andme_EA_allsnpinfo_allstat_noflips_ldpred_format.txt	  

#chr9	99995537	A	G	0.45517	0.95642	rs10125824	0.583158	0.00344735
#chr9	99995597	C	T	0.90608	0.93321	rs111737815	0.202055	0.0138137
#chr9	9999609	        A	G	0.96984	0.95414	rs118151312	0.367449	0.0165164
#chr9	99996301	A	G	0.99619	0.92434	rs141065662	0.619299	-0.0269425
#chr9	99996548	C	T	0.55162	0.9638	rs10981288	0.913033	-0.000684669
#chr9	99997049	A	G	0.45301	0.96044	rs10817273	0.574696	0.00352001
#chr9	99997707	C	T	0.5545	0.94544	rs11794422	0.813773	-0.00149156
#chr9	99998403	C	T	0.55076	0.96646	rs10981296	0.934372	-0.00051549
#chr9	99998646	C	G	0.8105	0.97813	rs10981297	0.112552	-0.0125128
#chr9	99999468	A	G	0.90628	0.93698	rs10981301	0.207239	0.0136444
			  
echo "Script finished"
date
echo
