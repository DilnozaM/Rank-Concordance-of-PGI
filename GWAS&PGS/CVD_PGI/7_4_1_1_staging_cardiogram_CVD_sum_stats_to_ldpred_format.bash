#!/bin/bash
#SBATCH -t 03:00:00
#SBATCH -N 1
#Adapted from Rita Pereira 

echo "Change the sum stats to ldpred format"
echo "Script started"
echo "CVD CARDIOGRAM"
date 

#change to the right directory
cd /path/projects/UKB_LDpred/CVD/CODE

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
python /path/tools/ldpred/ldpred-1.0.6/LDpred.py coord --help

#Unzip the sumstats
gunzip -c /path/projects/CVD/1_QC/CARDIOGRAM/OUTPUT/CVD/CLEANED.cad.add.160614.website.gz > /path/projects/UKB_LDpred/CVD/INPUT/CLEANED_cardiogram_CVD_sumstats.txt
 

#Organize sum stats 
head /path/projects/UKB_LDpred/CVD/INPUT/CLEANED_cardiogram_CVD_sumstats.txt

#1cptid          2rsID           3CHR    4POS       5EFFECT_ALLELE   6OTHER_ALLELE    7EAF            8BETA           9SE             10PVAL          11Z                 12INFO
#10:100000625    rs7899632       10      100000625       A                G           0.549923        0.03424         0.0091953       0.0001964       3.72364142551086    0.9995
#10:100000645    rs61875309      10      100000645       A                C           0.818372        -0.019443       0.0121891       0.1106876       -1.59511366712883   0.99812
#10:100003242    rs12258651      10      100003242       T                G           0.875632        0.010175        0.0138099       0.4612484       0.73679027364427    0.98798
#10:100003304    rs72828461      10      100003304       A                G           0.970065        -0.033679       0.0317356       0.2885823       -1.06123722255133   0.732
#10:100003785    rs1359508       10      100003785       T                C           0.642467        -0.023418       0.0095299       0.013998        -2.45731854479061   0.999
#10:100004360    rs1048754       10      100004360       G                A           0.818554        -0.01972        0.0121924       0.1057913       -1.61740100390407   0.99896
#10:100004906    rs3750595       10      100004906       C                A           0.549972        0.034491        0.0091964       0.0001765       3.75048932190857    0.99997
#10:100004996    rs2025625       10      100004996       G                A           0.642604        -0.02366        0.009531        0.0130492       -2.48242576854475   0.999
#10:100005282    rs10786405      10      100005282       C                T           0.550158        0.034821        0.0091997       0.0001537       3.78501472874115    0.99946


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
#info = $12
#rs = rsid = $2
#pval = $10
#effalt = $8
awk -F" " 'BEGIN{OFS="\t"; print "chr", "pos", "ref", "alt", "reffrq", "info", "rs", "pval", "effalt"} 
                 {if(NR>1) {print "chr"$3, $4, $5, $6, $7, $12, $2, $10, $8}}' OFS="\t" \
                  /path/projects/UKB_LDpred/CVD/INPUT/CLEANED_cardiogram_CVD_sumstats.txt > /path/projects/UKB_LDpred/CVD/INPUT/GWAS_cardiogram_CVD_ldpred_format.txt


echo "head sum stats"
head /path/projects/UKB_LDpred/CVD/INPUT/GWAS_cardiogram_CVD_ldpred_format.txt
#chr	pos	ref	alt	reffrq	info	rs	pval	effalt
#chr10	100000625	A	G	0.549923	0.9995	rs7899632	0.0001964	0.03424
#chr10	100000645	A	C	0.818372	0.99812	rs61875309	0.1106876	-0.019443
#chr10	100003242	T	G	0.875632	0.98798	rs12258651	0.4612484	0.010175
#chr10	100003304	A	G	0.970065	0.732	rs72828461	0.2885823	-0.033679
#chr10	100003785	T	C	0.642467	0.999	rs1359508	0.013998	-0.023418
#chr10	100004360	G	A	0.818554	0.99896	rs1048754	0.1057913	-0.01972
#chr10	100004906	C	A	0.549972	0.99997	rs3750595	0.0001765	0.034491
#chr10	100004996	G	A	0.642604	0.999	rs2025625	0.0130492	-0.02366
#chr10	100005282	C	T	0.550158	0.99946	rs10786405	0.0001537	0.034821

echo "tail sum stats"
tail /path/projects/UKB_LDpred/CVD/INPUT/GWAS_cardiogram_CVD_ldpred_format.txt	  
#chr9	99992137	A	G	0.463459	0.96843	rs10759526	0.064501	0.017871
#chr9	99992220	T	C	0.547838	0.98194	rs10817265	0.302058	0.009917
#chr9	99992496	T	A	0.267634	0.97741	rs7047367	0.1609803	0.01578
#chr9	99994643	G	C	0.459263	0.97794	rs6478025	0.072087	0.017318
#chr9	99994932	C	T	0.268511	0.977	rs7875158	0.1677046	0.015514
#chr9	99995270	C	G	0.459713	0.978	rs10981278	0.0719675	0.017337
#chr9	9999539	A	G	0.168801	0.967655	rs1936368	0.8424584	0.002564
#chr9	99995537	A	G	0.462701	0.973	rs10125824	0.0597197	0.018193
#chr9	99996634	T	G	0.458617	0.981	rs10759527	0.0588605	0.018152
#chr9	99997049	A	G	0.459299	0.982	rs10817273	0.0607114	0.018025


echo "Script finished"
date
echo
