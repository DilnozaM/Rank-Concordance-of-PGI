#!/bin/bash
#SBATCH -t 03:00:00
#SBATCH -N 1
#Adapted from Rita Pereira 

echo "Change the sum stats to ldpred format"
echo "Script started"
echo "EA NEW"
date 

#change to the right directory
cd /lustre5/0/geighei/projects/UKB_LDpred/EA_new/CODE

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
gunzip -c /lustre5/0/geighei/projects/UKB_QC/OUTPUT/UKB/EA_new/CLEANED.ukb_ea_new_fastgwa_mlm_excl_sibs_sibrels_resid_qc.fastGWA.gz > /lustre5/0/geighei/projects/UKB_LDpred/EA_new/INPUT/CLEANED_UKB_EA_new_sans_sibs_plus_rels_fastgwa.txt


#Organize sum stats 
head /lustre5/0/geighei/projects/UKB_LDpred/EA_new/INPUT/CLEANED_UKB_EA_new_sans_sibs_plus_rels_fastgwa.txt

#1cptid          2rsID           3CHR    4POS        5EFFECT_ALLELE   6OTHER_ALLELE    7EAF            8MAC    9BETA           10SE            11PVAL          12Z                  13INFO          14N     15N_eff
#10:100000625    rs7899632       10      100000625       A             G               0.566952        337300  0.00886916      0.0112481       0.430401        0.78850294716441     0.999653        389419  389216
#10:100000645    rs61875309      10      100000645       A             C               0.794671        159900  -0.0137707      0.0138083       0.318632        -0.997277000065178   0.999278        389419  388610
#10:100001867    rs150203744     10      100001867       C             T               0.985988        10910   -0.0207         0.0497084       0.677097        -0.41642861166322   0.911954         389419  354161
#10:100002378    rs185724698     10      100002378       T             C               0.998336        1296    -0.0179284      0.145351        0.901834        -0.123345556618118   0.886747        389419  344481
#10:100002464    rs111551711     10      100002464       T             C               0.986509        10510   0.0479643       0.0506019       0.343193        0.94787547503157     0.913422        389419  354775
#10:100003242    rs12258651      10      100003242       T             G               0.884972        89590   0.0253099       0.0174796       0.147627        1.44796791688597     0.999416        389419  388719
#10:100003304    rs72828461      10      100003304       A             G               0.960381        30860   0.00634388      0.0286075       0.824504        0.221755833260509    0.997275        389419  388262
#10:100003516    rs185989018     10      100003516       G             A               0.993235        5269    -0.0100235      0.0706454       0.887171        -0.141884680389664   0.926364        389419  360532
#10:10000360     rs7919605       10      10000360        G             A               0.998052        1517    -0.0396874      0.140408        0.777439        -0.282657683322888   0.811555        389419  315432


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
#pval = $11
#effalt = $9
awk -F" " 'BEGIN{OFS="\t"; print "chr", "pos", "ref", "alt", "reffrq", "info", "rs", "pval", "effalt"} 
                 {if(NR>1) {print "chr"$3, $4, $5, $6, $7, $13, $2, $11, $9}}' OFS="\t" \
                  /lustre5/0/geighei/projects/UKB_LDpred/EA_new/INPUT/CLEANED_UKB_EA_new_sans_sibs_plus_rels_fastgwa.txt > /lustre5/0/geighei/projects/UKB_LDpred/EA_new/INPUT/UKB_EA_new_sans_sibs_plus_rels_fastgwa_ldpred_format.txt


#Formula for beta=z-score/sqrt(N*2*MAF*(1-MAF))

echo "head sum stats"
head /lustre5/0/geighei/projects/UKB_LDpred/EA_new/INPUT/UKB_EA_new_sans_sibs_plus_rels_fastgwa_ldpred_format.txt
#chr	pos	       ref	alt	reffrq	        info	        rs	        pval	        effalt
#chr10	100000625	A	G	0.566952	0.999653	rs7899632	0.430401	0.00886916
#chr10	100000645	A	C	0.794671	0.999278	rs61875309	0.318632	-0.0137707
#chr10	100001867	C	T	0.985988	0.911954	rs150203744	0.677097	-0.0207
#hr10	100002378	T	C	0.998336	0.886747	rs185724698	0.901834	-0.0179284
#chr10	100002464	T	C	0.986509	0.913422	rs111551711	0.343193	0.0479643
#chr10	100003242	T	G	0.884972	0.999416	rs12258651	0.147627	0.0253099
#chr10	100003304	A	G	0.960381	0.997275	rs72828461	0.824504	0.00634388
#chr10	100003516	G	A	0.993235	0.926364	rs185989018	0.887171	-0.0100235
#chr10	10000360	G	A	0.998052	0.811555	rs7919605	0.777439	-0.0396874

echo "tail sum stats"
tail /lustre5/0/geighei/projects/UKB_LDpred/EA_new/INPUT/UKB_EA_new_sans_sibs_plus_rels_fastgwa_ldpred_format.txt	  
#chr9	99997049	A	G	0.451369	0.999621	rs10817273	0.0483705	-0.022139
#chr9	99997596	G	A	0.997251	0.998527	rs41405653	0.647308	0.0487821
#chr9	99997707	C	T	0.546441	0.99982	        rs11794422	0.0301215	-0.0242959
#chr9	99998403	C	T	0.549179	0.999849	rs10981296	0.0267795	-0.0248242
#chr9	99998646	C	G	0.810049	0.998939	rs10981297	0.49448	        -0.00972804
#chr9	9999880	        G	C	0.986793	0.826168	rs151001359	0.236661	-0.0635834
#chr9	99999154	G	A	0.997896	0.954351	rs80110029	0.598196	0.0657029
#chr9	99999366	T	G	0.997538	0.998585	rs80077755	0.527483	0.0711547
#chr9	99999468	A	G	0.905342	0.999122	rs10981301	0.683425	0.00777003
#chr3	195506435	G	T	0.250743	0.811382	rs379344	0.448591	0.0108349

echo "Script finished"
date
echo
