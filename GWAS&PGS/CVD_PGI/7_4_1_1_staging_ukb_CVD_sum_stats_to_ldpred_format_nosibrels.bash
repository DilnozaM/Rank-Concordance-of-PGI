#!/bin/bash
#SBATCH -t 03:00:00
#SBATCH -N 1
#Adapted from Rita Pereira 

echo "Change the sum stats to ldpred format"
echo "Script started"
echo "UKB CVD No Siblings No Sibling Relatives"
date 

#change to the right directory
cd /lustre5/0/geighei/projects/UKB_LDpred/CVD/CODE

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
gunzip -c /path/projects/UKB_QC/OUTPUT/UKB/CVD/CLEANED.ukb_CVD_fastgwa_mlm_excl_sibs_sibrels_resid.fastGWA.gz > /path/projects/UKB_LDpred/CVD/INPUT/CLEANED_ukb_CVD_fastgwa_mlm_excl_sibs_sibrels.txt


#Organize sum stats 
head /path/projects/UKB_LDpred/CVD/INPUT/CLEANED_ukb_CVD_fastgwa_mlm_excl_sibs_sibrels.txt

#1cptid          2rsID           3CHR    4POS       5EFFECT_ALLELE   6OTHER_ALLELE    7EAF            8MAC    9BETA           10SE            11PVAL          12Z                  13INFO          14N     15N_eff
#10:100000625    rs7899632       10      100000625       A                G           0.566892        340200  0.000755262     0.000587308     0.198453        1.28597260721802     0.999655        392771  393209
#10:100000645    rs61875309      10      100000645       A                C           0.794658        161300  -0.000332086    0.000720929     0.64506         -0.46063620689416    0.999276        392771  392653
#10:100001867    rs150203744     10      100001867       C                T           0.98599         11010   -0.0040897      0.0025952       0.115055        -1.57587083847102    0.912048        392771  357931
#10:100002378    rs185724698     10      100002378       T                C           0.998341        1303    -0.00716108     0.00760117      0.34614         -0.942102334245912   0.886751        392771  347989
#10:100002464    rs111551711     10      100002464       T                C           0.986511        10600   -0.00231217     0.0026424       0.381559        -0.875026491068725   0.913465        392771  358404
#10:100003242    rs12258651      10      100003242       T                G           0.884959        90370   0.00126802      0.000912665     0.164723        1.38935973221281     0.999416        392771  392693
#10:100003304    rs72828461      10      100003304       A                G           0.960388        31120   0.00191148      0.00149393      0.200723        1.27949770069548     0.99728         392771  392209
#10:100003516    rs185989018     10      100003516       G                A           0.993242        5309    0.0083527       0.00369098      0.0236357       2.26300332161106     0.926291        392771  364162
#10:10000360     rs7919605       10      10000360        G                A           0.998057        1526    0.0118321       0.00733971      0.106946        1.61206641679303     0.811936        392771  318761


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
                  /path/projects/UKB_LDpred/CVD/INPUT/CLEANED_ukb_CVD_fastgwa_mlm_excl_sibs_sibrels.txt > /path/projects/UKB_LDpred/CVD/INPUT/GWAS_ukb_CVD_UKBnosibsrels_ldpred_format.txt


echo "head sum stats"
head /path/projects/UKB_LDpred/CVD/INPUT/GWAS_ukb_CVD_UKBnosibsrels_ldpred_format.txt
#chr	pos	       ref	alt	reffrq	        info	        rs	        pval	        effalt
#chr10	100000625	A	G	0.566892	0.999655	rs7899632	0.198453	0.000755262
#chr10	100000645	A	C	0.794658	0.999276	rs61875309	0.64506	        -0.000332086
#chr10	100001867	C	T	0.98599	        0.912048	rs150203744	0.115055	-0.0040897
#chr10	100002378	T	C	0.998341	0.886751	rs185724698	0.34614	        -0.00716108
#chr10	100002464	T	C	0.986511	0.913465	rs111551711	0.381559	-0.00231217
#chr10	100003242	T	G	0.884959	0.999416	rs12258651	0.164723	0.00126802
#chr10	100003304	A	G	0.960388	0.99728	        rs72828461	0.200723	0.00191148
#chr10	100003516	G	A	0.993242	0.926291	rs185989018	0.0236357	0.0083527
#chr10	10000360	G	A	0.998057	0.811936	rs7919605	0.106946	0.0118321


echo "tail sum stats"
tail /path/projects/UKB_LDpred/CVD/INPUT/GWAS_ukb_CVD_UKBnosibsrels_ldpred_format.txt	  
#chr9	99997049	A	G	0.451309	0.999623	rs10817273	0.330735	0.000569508
#chr9	99997596	G	A	0.997237	0.998489	rs41405653	0.230268	0.00666147
#chr9	99997707	C	T	0.546361	0.999818	rs11794422	0.629353	0.000282332
#chr9	99998403	C	T	0.549114	0.99985	        rs10981296	0.723624	0.000206948
#chr9	99998646	C	G	0.810059	0.998938	rs10981297	0.525555	-0.000472022
#chr9	9999880 	G	C	0.986779	0.82638	        rs151001359	0.121035	0.00434706
#chr9	99999154	G	A	0.997898	0.954257	rs80110029	0.565417	0.00374163
#chr9	99999366	T	G	0.997524	0.998565	rs80077755	0.254567	0.00667967
#chr9	99999468	A	G	0.905362	0.999128	rs10981301	0.367906	0.000895858
#chr3	195506435	G	T	0.250745	0.811369	rs379344	0.994787	-4.87897e-06


echo "Script finished"
date
echo
