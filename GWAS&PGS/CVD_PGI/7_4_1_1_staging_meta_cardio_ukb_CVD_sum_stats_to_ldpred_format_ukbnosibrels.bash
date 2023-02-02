#!/bin/bash
#SBATCH -t 03:00:00
#SBATCH -N 1
#Adapted from Rita Pereira 

echo "Change the sum stats to ldpred format"
echo "Script started"
echo "CVD Meta Cardiogram & UKB nosibrels"
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
gunzip -c /path/projects/CVD/3_METAL/OUTPUT/GWAS_meta_CVD_CARDIOGRAM_UKBnosibsrels.txt.gz > /path/projects/UKB_LDpred/CVD/INPUT/GWAS_meta_CVD_CARDIOGRAM_UKBnosibsrels.txt


#Organize sum stats 
head /path/projects/UKB_LDpred/CVD/INPUT/GWAS_meta_CVD_CARDIOGRAM_UKBnosibsrels.txt

#1CHR    2POS            3rsid      4EFFECT_ALLELE   5OTHER_ALLELE    6EAF    7EAF_SE 8MIN_EAF 9MAX_EAF 10N             11Z     12P-value 13Direction     14HetISq  15HetChiSq      16HetDf 17HetPVal
#6       130840091       rs2326918       a                g           0.8457  0.0011  0.8433   0.8462   474257.00       0.103   0.918     -+              14.2      1.166           1       0.2802
#3       104998275       rs112634005     a                c           0.9948  0.0000  0.9948   0.9948   392771.00       2.452   0.01422   +?              0.0       0.000           0       1
#13      33786576        rs151222586     a                g           0.9965  0.0000  0.9965   0.9965   392771.00       1.109   0.2673    +?              0.0       0.000           0       1
#20      8411670         rs6039163       t                c           0.9983  0.0000  0.9983   0.9983   392771.00       -0.421  0.6741    -?              0.0       0.000           0       1
#3       176666749       rs66941928      t                c           0.8006  0.0049  0.7898   0.8028   474257.00       0.294   0.7689    +-              42.9      1.751           1       0.1857
#7       34606102        rs146253013     t                c           0.9956  0.0000  0.9956   0.9956   392771.00       -1.717  0.08594   -?              0.0       0.000           0       1
#16      8600861         rs7190157       a                c           0.6099  0.0936  0.4043   0.6525   474257.00       -1.251  0.2108    -+              0.0       0.337           1       0.5617
#11      100009976       rs12364336      a                g           0.8700  0.0034  0.8685   0.8774   474257.00       -0.649  0.5165    --              0.0       0.459           1       0.4979
#7       145771806       rs6977693       t                c           0.8588  0.0082  0.8551   0.8769   474257.00       0.889   0.3739    +-              68.4      3.166           1       0.07517


## LDpred REQUIRES THE FOLLOWING FORMAT:
## chr     pos     ref     alt     reffrq  info    rs          pval    effalt
## chr1    1020428  C       T     0.85083  0.98732 rs6687776   0.0587  -0.014



#Checking which one is the reference allele 
# EFFECT_ALLLELE is the reference allele. 

# column separator is either a : or a tab 
#chr = $1
#pos = $2
#ref = EFFECT_ALLELE = $4
#alt = OTHER_ALLELE = $5
#reff freq = EAF = $6
#info = "NaN"
#rs = rsid = $3
#pval = $12
#effalt = 1*($11/sqrt($10*2*$6*(1-$6)))
awk -F" " 'BEGIN{OFS="\t"; print "chr", "pos", "ref", "alt", "reffrq", "info", "rs", "pval", "effalt"} 
                 {if(NR>1) {print "chr"$1, $2, $4, $5, $6, "NaN", $3, $12, 1*($11/sqrt($10*2*$6*(1-$6)))}}' OFS="\t" \
                  /path/projects/UKB_LDpred/CVD/INPUT/GWAS_meta_CVD_CARDIOGRAM_UKBnosibsrels.txt > /path/projects/UKB_LDpred/CVD/INPUT/GWAS_meta_CVD_CARDIOGRAM_UKBnosibsrels_ldpred_format.txt

#Formula for beta=z-score/sqrt(N*2*MAF*(1-MAF))

echo "head sum stats"
head /path/projects/UKB_LDpred/CVD/INPUT/GWAS_meta_CVD_CARDIOGRAM_UKBnosibsrels_ldpred_format.txt
#chr	pos	       ref	alt	reffrq	info	rs	        pval	effalt
#chr6	130840091	a	g	0.8457	NaN	rs2326918	0.918	0.000292768
#chr3	104998275	a	c	0.9948	NaN	rs112634005	0.01422	0.038465
#chr13	33786576	a	g	0.9965	NaN	rs151222586	0.2673	0.0211872
#chr20	8411670	        t	c	0.9983	NaN	rs6039163	0.6741	-0.0115303
#chr3	176666749	t	c	0.8006	NaN	rs66941928	0.7689	0.000755536
#chr7	34606102	t	c	0.9956	NaN	rs146253013	0.08594	-0.0292696
#chr16	8600861	        a	c	0.6099	NaN	rs7190157	0.2108	-0.00263341
#chr11	100009976	a	g	0.8700	NaN	rs12364336	0.5165	-0.00198149
#chr7	145771806	t	c	0.8588	NaN	rs6977693	0.3739	0.0026213

echo "tail sum stats"
tail /path/projects/UKB_LDpred/CVD/INPUT/GWAS_meta_CVD_CARDIOGRAM_UKBnosibsrels_ldpred_format.txt	  
#chr7	107988681	a	t	0.8041	NaN	rs117878361	0.6814	  -0.00106328
#chr15	50176748	a	g	0.9911	NaN	rs569284138	0.3498	  -0.0112324
#chr5	37232736	a	c	0.9948	NaN	rs113147370	0.5782	  -0.00872209
#chr10	45000528	a	g	0.9962	NaN	rs61857792	0.3892	  0.015789
#chr15	62030949	t	c	0.5936	NaN	rs2414744	0.4813	  0.00147173
#chr20	33400913	t	g	0.5705	NaN	rs7262834	2.812e-05 0.00868711
#chr1	84241498	t	c	0.8499	NaN	rs4140461	0.2231	  -0.00350148
#chr12	44074208	t	c	0.9407	NaN	rs117241566	0.6668	  0.00187371
#chr6	133446510	t	c	0.9988	NaN	rs6923351	0.5762	  -0.0182179
#chr9	33326563	c	g	0.7277	NaN	rs35315823	0.3543	  0.00213594

echo "Script finished"
date
echo
